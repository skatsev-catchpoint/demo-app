import React, { useEffect, useState } from "react";

function App() {
  const [message, setMessage] = useState("Loading...");

  useEffect(() => {
    fetch("/api/")
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP error! Status: ${res.status}`);
        return res.text();
      })
      .then((data) => setMessage(data))
      .catch((err) => {
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

export default App;
