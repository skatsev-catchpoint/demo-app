set -x

if [ -z "$CATCHPOINT_TOKEN" ]; then
  echo "ERROR: CATCHPOINT_TOKEN is not set or empty."
  exit 1
fi

echo "Running WebPageTest with Catchpoint..."

RESPONSE=$(curl -s -X 'POST' \
            'https://io.catchpoint.com/api/v4/webpagetest/test' \
            -H 'accept: application/json' \
            -H "Authorization: Bearer $CATCHPOINT_TOKEN" \
            -H 'Content-Type: application/json' \
            -d '{
              "url": "http://www.sergeykatsev.com:3000/",
              "runs": 1,
              "nodeId": 4790,
              "connectionType": 11,
              "deviceType": 22,
              "deviceResolution": 2,
              "firstViewOnly": true,
              "lighthouse": false,
              "performance": true,
              "chromiumParameters": {
                "carbonControl": false,
                "useDevToolsTrafficShaper": true,
                "hostResolverRules": "string",
                "captureDevToolsTimeline": true
              }
            }')

# Parse the ID from the response
ID=$(echo "$RESPONSE" | jq -r '.data.id')

get_results() {
  TMPFILE=$(mktemp)
  CODE=$(curl -s -o "$TMPFILE" -w "%{http_code}" -X 'GET' \
    "https://io.catchpoint.com/api/v4/webpagetest/results/$ID?run=1&includeWaterfall=false&includeFilmstrip=false&includeLighthouse=false" \
    -H 'accept: application/json' -H "Authorization: Bearer $CATCHPOINT_TOKEN")
  # Return code and file path
  echo "$CODE $TMPFILE"
}

MAX_RETRIES=6
RETRY=1

while [ $RETRY -le $MAX_RETRIES ]; do
  RESULT=$(get_results)
  HTTP_CODE=$(echo "$RESULT" | awk '{print $1}')
  TMPFILE=$(echo "$RESULT" | awk '{print $2}')

  if [ "$HTTP_CODE" -eq 200 ]; then
    cp "$TMPFILE" wpt_result.json
    rm "$TMPFILE"
    break
  else
    echo "Attempt $RETRY failed with HTTP $HTTP_CODE, waiting 5 seconds before retrying..."
    sleep 5
    RETRY=$((RETRY + 1))
    rm "$TMPFILE"
  fi
done

if [ "$HTTP_CODE" -ne 200 ]; then
  echo "All $MAX_RETRIES attempts failed. Last HTTP code: $HTTP_CODE"
  cat "$TMPFILE"
  rm "$TMPFILE"
  exit 1
fi

# Check for errors in the JSON
ERROR_COUNT=$(jq '.errors | length' wpt_result.json)
if [ "$ERROR_COUNT" -gt 0 ]; then
  ERRORS=$(jq -c '.errors' wpt_result.json)
  echo "WebPageTest returned errors: $ERRORS"
  exit 2
fi

DATA_ERROR=$(jq -r '.data.error // empty' wpt_result.json)
if [ -n "$DATA_ERROR" ]; then
  echo "WebPageTest run error: $DATA_ERROR"
  exit 2
fi

# Google recommended good values (as of 2024):
TTFB_THRESHOLD=800        # ms
FCP_THRESHOLD=1800        # ms
LCP_THRESHOLD=2500        # ms
CLS_THRESHOLD=0.1         # unitless
DOC_COMPLETE_THRESHOLD=2500 # ms

# Extract metrics from the WPT result
TTFB=$(jq '.data.runs[0].timeToFirstByte' wpt_result.json)
FCP=$(jq '.data.runs[0].firstContentfulPaint' wpt_result.json)
LCP=$(jq '.data.runs[0].largestContentfulPaint' wpt_result.json)
CLS=$(jq '.data.runs[0].cumulativeLayoutShift' wpt_result.json)
DOC_COMPLETE=$(jq '.data.runs[0].docTime' wpt_result.json)

echo "TTFB: $TTFB ms (threshold: $TTFB_THRESHOLD ms)"
echo "FCP: $FCP ms (threshold: $FCP_THRESHOLD ms)"
echo "LCP: $LCP ms (threshold: $LCP_THRESHOLD ms)"
echo "CLS: $CLS (threshold: $CLS_THRESHOLD)"
echo "Document Complete: $DOC_COMPLETE ms (threshold: $DOC_COMPLETE_THRESHOLD ms)"

FAIL=0

# Use bc for all comparisons to handle floats
if [ "$(echo "$TTFB > $TTFB_THRESHOLD" | bc)" -eq 1 ]; then
  echo "ERROR: TTFB ($TTFB ms) exceeds threshold ($TTFB_THRESHOLD ms)"
  FAIL=1
fi

if [ "$(echo "$FCP > $FCP_THRESHOLD" | bc)" -eq 1 ]; then
  echo "ERROR: FCP ($FCP ms) exceeds threshold ($FCP_THRESHOLD ms)"
  FAIL=1
fi

if [ "$(echo "$LCP > $LCP_THRESHOLD" | bc)" -eq 1 ]; then
  echo "ERROR: LCP ($LCP ms) exceeds threshold ($LCP_THRESHOLD ms)"
  FAIL=1
fi

if [ "$(echo "$CLS > $CLS_THRESHOLD" | bc)" -eq 1 ]; then
  echo "ERROR: CLS ($CLS) exceeds threshold ($CLS_THRESHOLD)"
  FAIL=1
fi

if [ "$(echo "$DOC_COMPLETE > $DOC_COMPLETE_THRESHOLD" | bc)" -eq 1 ]; then
  echo "ERROR: Document Complete ($DOC_COMPLETE ms) exceeds threshold ($DOC_COMPLETE_THRESHOLD ms)"
  FAIL=1
fi

if [ "$FAIL" -eq 1 ]; then
  echo "One or more metrics failed Google recommended thresholds."
  exit 2
else
  echo "All metrics are within Google recommended thresholds."
  exit 0
fi
