# Study Group Finder Backend API

Complete API reference for the backend in this folder, with Postman examples for every endpoint.

## Base URL

- Local: `http://localhost:5000/api`
- Production: replace with your deployed API domain

## Authentication

Protected endpoints require:

`Authorization: Bearer <JWT_TOKEN>`

Get the token from `POST /auth/login`.

---

## Quick Postman Setup

1. Import `backend/postman/STUDY_GROUP_FINDER_API.postman_collection.json`.
2. Create an environment with:
   - `baseUrl` = `http://localhost:5000/api`
   - `token` = (leave empty initially)
   - `groupId` = (leave empty initially)
   - `userId` = (leave empty initially)
3. Run **Auth > Login** and copy token into `token` env var.
4. Use the rest of the requests.

---

## Live Test Snapshot (from local run)

Tested on `2026-04-14` against local backend:

- `GET /health` -> `200`
- `POST /auth/register` -> `201`
- `POST /auth/login` -> `200`
- `GET /auth/me` -> `200`
- `POST /groups` -> `201`
- `GET /groups` -> `200`
- `GET /groups/:id` -> `200`
- `POST /groups/:id/join` -> `200`
- `POST /posts/group/:groupId` -> `201`
- `GET /posts/group/:groupId` -> `200`
- `POST /sessions/group/:groupId` -> `201`
- `GET /sessions/group/:groupId` -> `200`
- `DELETE /groups/:id/members/:userId` -> `200`
- `POST /chat/messages` -> `201`
- `GET /chat/messages` -> `200`
- `PUT /groups/:id/leader/:userId` as `STUDENT` -> `403` (expected)
- `GET /groups/feedback/admin/join` as `STUDENT` -> `403` (expected)

---

## Endpoints and Examples

### 1) Health

#### GET `/health`

Checks API availability.

Example response:

```json
{
  "status": "API is running"
}
```

### 2) Auth

#### POST `/auth/register`

Creates a new user.

Example body:

```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "password": "TestPass123!",
  "program_of_study": "BSIT",
  "year_of_study": 1,
  "role": "STUDENT"
}
```

Example response:

```json
{
  "message": "User registered successfully",
  "userId": 10
}
```

Notes:
- Allowed role values: `STUDENT`, `ADMIN`
- `ADMIN` registration requires valid admin signup code or existing admin token.

#### POST `/auth/login`

Logs in and returns JWT token.

Example body:

```json
{
  "email": "jane@example.com",
  "password": "TestPass123!"
}
```

Example response:

```json
{
  "token": "<JWT_TOKEN>",
  "user": {
    "id": 10,
    "name": "Jane Doe",
    "role": "STUDENT"
  }
}
```

#### GET `/auth/me` (Protected)

Returns currently authenticated user profile.

Example response:

```json
{
  "user": {
    "id": 10,
    "name": "Jane Doe",
    "email": "jane@example.com",
    "role": "STUDENT",
    "program_of_study": "BSIT",
    "year_of_study": 1
  }
}
```

### 3) Groups

#### POST `/groups` (Protected)

Creates a group. Creator is auto-added as `LEADER`.

Example body:

```json
{
  "name": "Data Structures Review",
  "course_name_code": "IT101",
  "description": "Weekly review sessions",
  "location": "Library Room 2",
  "faculty": "CCS",
  "maxCapacity": 10,
  "isVirtual": false
}
```

Example response:

```json
{
  "id": 5,
  "name": "Data Structures Review",
  "course_name_code": "IT101",
  "description": "Weekly review sessions",
  "location": "Library Room 2",
  "faculty": "CCS",
  "maxCapacity": 10,
  "isVirtual": false
}
```

#### GET `/groups`

Returns all groups with member summaries.

Example response (trimmed):

```json
[
  {
    "id": 5,
    "name": "Data Structures Review",
    "members": [
      {
        "id": 10,
        "name": "Jane Doe",
        "role": "STUDENT",
        "GroupMember": {
          "role": "LEADER"
        }
      }
    ]
  }
]
```

#### GET `/groups/:id`

Returns one group by ID.

Example:
- `GET /groups/5`

#### POST `/groups/:id/join` (Protected)

Adds current user as group member.

Example:
- `POST /groups/5/join`

Example response:

```json
{
  "message": "Joined group successfully"
}
```

#### DELETE `/groups/:id/members/:userId` (Protected)

Removes a member.

Rules:
- Leader can remove others in the group.
- A user can remove themself.

Example:
- `DELETE /groups/5/members/10`

Example response:

```json
{
  "message": "Member removed"
}
```

#### PUT `/groups/:id/leader/:userId` (Protected, Admin only)

Assigns group leader to a student member (admin action).

Example:
- `PUT /groups/5/leader/10`

Student token response example:

```json
{
  "error": "Only admins can assign a group leader"
}
```

#### GET `/groups/feedback/admin/join` (Protected, Admin only)

Returns recent student joins feedback.

Student token response example:

```json
{
  "error": "Only admins can access join feedback"
}
```

### 4) Sessions

#### POST `/sessions/group/:groupId` (Protected)

Creates a session for a group.

Example body:

```json
{
  "date": "2026-04-20",
  "time": "14:00",
  "location": "Room 101",
  "description": "Backend API testing session"
}
```

Example:
- `POST /sessions/group/5`

Example response:

```json
{
  "id": 3,
  "groupId": "5",
  "date": "2026-04-20",
  "time": "14:00",
  "location": "Room 101",
  "description": "Backend API testing session"
}
```

#### GET `/sessions/group/:groupId` (Protected)

Lists sessions for group.

Example:
- `GET /sessions/group/5`

### 5) Posts

#### POST `/posts/group/:groupId` (Protected)

Creates a post in a group.

Example body:

```json
{
  "content": "Hello team, let's meet at 2pm."
}
```

Example response:

```json
{
  "id": 3,
  "groupId": "5",
  "userId": 10,
  "content": "Hello team, let's meet at 2pm."
}
```

#### GET `/posts/group/:groupId` (Protected)

Lists posts for a group with author details.

Example:
- `GET /posts/group/5`

### 6) Chat

#### GET `/chat/messages` (Protected)

Fetches chat messages by room.

Query parameters:
- `room` (optional, default `global`)
- `limit` (optional, default `100`, max `200`)

Example:
- `GET /chat/messages?room=global&limit=20`

#### POST `/chat/messages` (Protected)

Sends chat message.

Example body:

```json
{
  "room": "global",
  "content": "Hello chat API"
}
```

Example response:

```json
{
  "id": 5,
  "room": "global",
  "content": "Hello chat API",
  "userId": 10,
  "sender": {
    "id": 10,
    "name": "Jane Doe",
    "role": "STUDENT"
  }
}
```

---

## Common Error Responses

```json
{
  "error": "Authentication token required"
}
```

```json
{
  "error": "Invalid or expired token"
}
```

```json
{
  "error": "Server error"
}
```
