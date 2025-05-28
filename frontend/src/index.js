import React, { useEffect, useState } from "react";
import ReactDOM from "react-dom/client";

function App() {
  const [message, setMessage] = useState("Loading...");

  useEffect(() => {
    fetch("http://localhost:3001/")
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP error! Status: ${res.status}`);
        return res.text();
      })
      .then((data) => setMessage(data))
      .catch((err) => {
        // CORS errors are opaque and show as TypeError: Failed to fetch
        if (err instanceof TypeError && err.message === "Failed to fetch") {
          setMessage("CORS error: Unable to reach backend due to CORS policy.");
        } else {
          setMessage("Error: " + err.message);
        }
      });
  }, []);

  return (
    <div>
      <h1>Backend says:</h1>
      <p>{message}</p>
    </div>
  );
}

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(<App />);
