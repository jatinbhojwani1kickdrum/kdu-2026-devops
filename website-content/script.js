const API_URL = "https://fjl87l1q3e.execute-api.us-east-2.amazonaws.com/prod/messages";

async function loadMessages() {
  try {
    const response = await fetch(API_URL);
    const data = await response.json();

    const list = document.getElementById("messageList");
    list.innerHTML = "";

    data.forEach((item) => {
      const li = document.createElement("li");

      const messageText = document.createElement("div");
      messageText.textContent = item.message;

      const timeText = document.createElement("small");
      const date = new Date(Number(item.createdAt));
      timeText.textContent = isNaN(date.getTime()) ? "" : date.toLocaleString();
      timeText.style.color = "#666";
      timeText.style.float = "right";

      li.appendChild(messageText);
      li.appendChild(timeText);

      list.appendChild(li);
    });
  } catch (err) {
    console.error(err);
    alert("Error loading messages");
  }
}

async function submitMessage() {
  const input = document.getElementById("messageInput");
  const message = (input.value || "").trim();

  if (!message) return;

  try {
    await fetch(API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message }),
    });

    input.value = "";
    loadMessages();
  } catch (err) {
    console.error(err);
    alert("Error submitting message");
  }
}

document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("submitBtn").addEventListener("click", submitMessage);

  // Allow Ctrl+Enter to submit from textarea
  document.getElementById("messageInput").addEventListener("keydown", (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key === "Enter") {
      submitMessage();
    }
  });

  loadMessages();
});