const API_BASE = "/api";

async function fetchUsers() {
  const res = await fetch(`${API_BASE}/users`);
  const data = await res.json();

  const list = document.getElementById("users");
  list.innerHTML = "";
  data.forEach(user => {
    const li = document.createElement("li");
    li.innerHTML = `${user.name} (${user.email})
      <button onclick="deleteUser(${user.id})">Delete</button>`;
    list.appendChild(li);
  });
}

async function createUser() {
  const name = document.getElementById("name").value;
  const email = document.getElementById("email").value;

  await fetch(`${API_BASE}/users`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name, email })
  });

  fetchUsers();
}

async function deleteUser(id) {
  await fetch(`${API_BASE}/users/${id}`, { method: "DELETE" });
  fetchUsers();
}

fetchUsers();