# Project Overview
ft_transcendance is a project of school 42 Lausanne, Switzerland

## Objective
- Develop a comprehensive web application that integrates user management, friendships, and a game feature, specifically a multiplayer version of the classic game Pong. The project focuses on building a secure and modular back-end using Django and Python, while ensuring seamless communication between the front-end and back-end through REST APIs.

- The application includes an implementation of Pong, a real-time multiplayer game where users can challenge each other and view their match history. The game logic is integrated into the application, allowing users to create game sessions, track scores, and update their player stats.
- Matchmaking features enable users to connect with others based on availability and preferences.

## Code Summary
### Technologies Used:
- Django & Python: Core framework and language for back-end development.
- Docker: Containerization of services to ensure a modular, consistent, and secure environment.
- Nginx: Reverse proxy server configuration for handling client requests.
- PostgreSQL: Database management for efficient and secure data storage.

### Security Measures:
- Input validation to prevent malicious data entry.
- Robust authentication mechanisms for secure login and user management.
- Access control policies to safeguard user data and application integrity.

# API Documentation

## User Endpoints

<details>
<summary>1. Register User</summary>

- **Endpoint**: `POST https://localhost:8000/api/user/register/`
- **Purpose**: Register a new user.
- **Permissions**: NoAuth, ALLOW_ANY
- **Request Format**:
    ```json
    {
        "id": "91bbdd08-1a78-4481-b4e9-0a2cf67e4c01",
        "username": "test",
        "password": "StrongPassword123!",
        "first_name": "test",
        "last_name": "test",
        "email": "test@gmail.com"
        // "profile_photo": "path/to/profile/photo.jpg" // optional
    }
    ```
- **Notes**:
    - Unique email and username are required.
    - Photos are uploaded to `./srcs/site/profile_photos/users/`.
    - Default profile photo is used if none is uploaded (`default-user-profile-photo.jpg`).
    - Uploaded photos appear in three containers: nginx (`/var/www/html/profile_photos/`), auth (`./media/profile_photos`), and postgres.
    - Check user registration in Django admin: `http://localhost:8000/api/user/admin`. (Profile photo not visible here.)
- **Response**:
    - `HTTP_201_CREATED`
        ```json
        {
            "id": "fc9c745a-8fd5-4c2f-979c-cfcc4d8f7399",
            "username": "user1",
            "email": "user1@gmail.com",
            "first_name": "user_first_name",
            "last_name": "user_last_name",
            "profile_photo": "https://localhost/profile_photos/default/default-user-profile-photo.jpg",
            "is_active": true,
            "date_joined": "11 Oct 2024 09:59",
            "last_login": null
        }
        ```
    - `HTTP_400_BAD_REQUEST`
        ```json
        {
            "username": [
                "A user with that username already exists."
            ],
            "email": [
                "User with this email already exists."
            ]
        }
        ```
</details>

<details>
<summary>2. Login User</summary>

- **Endpoint**: `POST https://localhost:8000/api/user/login/`
- **Purpose**: Log in a registered user.
- **Permissions**: NoAuth, ALLOW_ANY
- **Request Example**:
    ```json
    {
        "email": "test@gmail.com",
        "password": "StrongPassword123!"
    }
    ```
- **Response**:
    - `HTTP_200_OK` returns a sliding token:
        ```json
        {
            "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
            "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        }
        ```
    - `HTTP_401_UNAUTHORIZED`
        ```json
        {
            "detail": "Invalid mail or password"
        }
        ```
</details>

<details>
<summary>3. User Profile</summary>

- **Endpoint**: `GET/PUT/PATCH https://localhost:8000/api/user/profile/`
- **Purpose**: View or modify user profile details.
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Modifiable Fields**: First name, last name, email, profile photo, and deactivation (`is_active: false`).
- **Request Example**:
    ```json
    {
        "first_name": "new_first_name",
        "last_name": "new_last_name",
        "email": "new_email@gmail.com",
        "profile_photo": "path/to/new/photo.jpg"
    }
    ```
- **Response**:
    - `HTTP_200_OK`
        ```json
        {
            "id": "91bbdd08-1a78-4481-b4e9-0a2cf67e4c01",
            "username": "test",
            "email": "test@gmail.com",
            "first_name": "new_first_name",
            "last_name": "new_last_name",
            "is_active": true,
            "profile_photo": "https://localhost/profile_photos/default/default-user-profile-photo.jpg",
            "date_joined": "18 Sep 2024 11:16:59",
            "last_login": "18 Sep 2024 11:19:03",
            "updated_at": "18 Sep 2024 11:22:08"
        }
        ```
</details>

<details>
<summary>4. Change Password</summary>

- **Endpoint**: `PATCH https://localhost:8000/api/user/change-password/`
- **Purpose**: Update a user's password.
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Request Example**:
    ```json
    {
        "old_password": "StrongPassword123!",
        "new_password": "NEWStrongPassword123!",
        "new_password2": "NEWStrongPassword123!"
    }
    ```
- **Response**:
    - `HTTP_200_OK`
        ```json
        {
            "detail": "Password updated successfully."
        }
        ```
</details>

<details>
<summary>5. Logout</summary>

- **Endpoint**: `POST https://localhost:8000/api/user/logout/`
- **Purpose**: Log out and blacklist the refresh token.
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Request Example**:
    ```json
    {
        "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
    ```
- **Response**:
    - `HTTP_200_OK`
        ```json
        {
            "message": "Logout successful, token blacklisted."
        }
        ```
    - `HTTP_400_BAD_REQUEST`
        ```json
        {
            "error": "Refresh token field is required."
        }
        ```
</details>

<details>
<summary>6. Token Refresh</summary>

- **Endpoint**: `POST https://localhost:8000/api/user/token/refresh`
- **Purpose**: Refresh the token.
- **Permissions**: NoAuth, ALLOW_ANY
- **Request Example**:
    ```json
    {
        "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
    ```
- **Response**:
    - `HTTP_200_OK`
        ```json
        {
            "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
            "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        }
        ```
</details>

---

## Friends Endpoints

### General information
<details>
<summary><code>is_online</code> → Bool</summary>

- This field indicates if the user is currently online.
- It is added in the view `show-all-users` and all related endpoints below.

</details>

<details>
<summary><code>is_active_request</code> → Bool</summary>

- Indicates whether a friendship request is currently active.
- If `True`:
    - A friendship request has been sent.
    - The two users are not yet friends.
    - The request has not been canceled or declined.
    - `are_friends` will be `False`.

</details>

<details>
<summary><code>are_friends</code> → Bool</summary>

- Indicates whether the two users are friends.
- If `True`:
    - The two users are confirmed as friends.
    - `is_active_request` will be `False`.

</details>

### API information

<details>
<summary>1. Send Friend Request</summary>

- **Endpoint**: `POST https://localhost:8000/api/friends/send-friend-request/`
- **Purpose**: Send a friend request to another user.
- **Request Example**:
    ```json
    {
        "user_id": "91bbdd08-1a78-4481-b4e9-0a2cf67e4c01"
    }
    ```
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Response**:
    - `HTTP_201_CREATED`
        ```json
        {
            "message": "Friend request has been sent successfully."
        }
        ```
    - `HTTP_400_BAD_REQUEST`
        ```json
        {
            "error": "You are already friends with this user."
        }
        ```
    - `HTTP_404_NOT_FOUND`
        ```json
        {
            "error": "User with id '46750fe5-01b5-4712-ae8c-60d880ffe07e' not found."
        }
        ```
</details>

<details>
<summary>2. Show All Sent Requests</summary>

- **Endpoint**: `GET https://localhost:8000/api/friends/show-all-sent-requests/`
- **Purpose**: Display all the friend requests sent by the current user.
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Response**:
    - If there are requests:
        ```json
        [
            {
                "id": "64aeaa2e-bb71-4c8a-83b6-7deeb18dee8d",
                "receiver": {
                    "id": "38f9bc7f-fbd5-4f77-b954-efb934ebf6ce",
                    "username": "user2",
                    "email": "user2@gmail.com",
                    "first_name": "user2_first_name",
                    "last_name": "user2_last_name",
                    "is_online": true
                },
                "is_active_request": true,
                "are_friends": false,
                "timestamp": "02 Oct 2024 15:17:39"
            }
        ]
        ```
    - If there are no requests:
        ```json
        []
        ```
</details>

<details>
<summary>3. Show All Received Requests</summary>

- **Endpoint**: `GET https://localhost:8000/api/friends/show-all-received-requests/`
- **Purpose**: Display all the friend requests received by the current user.
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Response**:
    - If there are requests:
        ```json
        [
            {
                "id": "d7e02eae-3e03-43e1-b87a-bd49662b3032",
                "sender": {
                    "id": "91bbdd08-1a78-4481-b4e9-0a2cf67e4c01",
                    "username": "user1",
                    "email": "user1@gmail.com",
                    "first_name": "user1_first_name",
                    "last_name": "user1_last_name",
                    "is_online": true
                },
                "is_active_request": true,
                "are_friends": false,
                "timestamp": "02 Oct 2024 15:39:37"
            }
        ]
        ```
    - If there are no requests:
        ```json
        []
        ```
</details>

<details>
<summary>4. Show All Friends</summary>

- **Endpoint**: `GET https://localhost:8000/api/friends/show-all-friends/`
- **Purpose**: Display a list of friends for the current user.
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Response**:
    - If there are friends:
        ```json
        [
            {
                "id": "d7e02eae-3e03-43e1-b87a-bd49662b3032",
                "friend": {
                    "id": "91bbdd08-1a78-4481-b4e9-0a2cf67e4c01",
                    "username": "user1",
                    "email": "user1@gmail.com",
                    "first_name": "user1_first_name",
                    "last_name": "user1_last_name",
                    "is_online": true
                },
                "is_active_request": false,
                "are_friends": true,
                "timestamp": "02 Oct 2024 15:45:38"
            }
        ]
        ```
    - If there are no friends:
        ```json
        []
        ```
</details>

<details>
<summary>5. Accept Friend Request</summary>

- **Endpoint**: `PATCH https://localhost:8000/api/friends/accept-friend-request/`
- **Purpose**: Accept a friend request received by the current user.
- **Request Example**:
    ```json
    {
        "user_id": "38f9bc7f-fbd5-4f77-b954-efb934ebf6ce"
    }
    ```
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Response**:
    - `HTTP_200_OK`
        ```json
        {
            "message": "Friend request has been accepted successfully."
        }
        ```
    - `HTTP_400_BAD_REQUEST`
        ```json
        {
            "error": "Friend request not found."
        }
        ```
</details>

<details>
<summary>6. Cancel Friend Request</summary>

- **Endpoint**: `DELETE https://localhost:8000/api/friends/cancel-friend-request/`
- **Purpose**: Cancel a friend request sent by the current user.
- **Request Example**:
    ```json
    {
        "user_id": "38f9bc7f-fbd5-4f77-b954-efb934ebf6ce"
    }
    ```
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Response**:
    - `HTTP_200_OK`
        ```json
        {
            "message": "Friend request has been canceled."
        }
        ```
</details>

<details>
<summary>7. Decline Friend Request</summary>

- **Endpoint**: `DELETE https://localhost:8000/api/friends/decline-friend-request/`
- **Purpose**: Decline a friend request received by the current user.
- **Request Example**:
    ```json
    {
        "user_id": "38f9bc7f-fbd5-4f77-b954-efb934ebf6ce"
    }
    ```
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Response**:
    - `HTTP_200_OK`
        ```json
        {
            "message": "Friend request has been declined."
        }
        ```
</details>

<details>
<summary>8. Unfriend</summary>

- **Endpoint**: `DELETE https://localhost:8000/api/friends/unfriend/`
- **Purpose**: Remove a friend from the current user's friends list.
- **Request Example**:
    ```json
    {
        "user_id": "38f9bc7f-fbd5-4f77-b954-efb934ebf6ce"
    }
    ```
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Response**:
    - `HTTP_200_OK`
        ```json
        {
            "message": "Friendship has been removed successfully."
        }
        ```
</details>

---

## Game Endpoints

### General information

<details>
<summary>Game Mode Codes</summary>

To designate the game mode, use 2 uppercase characters according to the list:

```python
    "VS" = VERSUS
    "TN" = TOURNAMENT 
    "LS" = LAST_MAN_STANDING 
    "BB" = BRICK_BREAKER
```
</details>


<details>
<summary>Game Duration Format</summary>
```
"1 d, 5 hrs 10 min 58 sec"
"1 hrs 0 min 20 sec"
"2 min 55 sec"
"37 sec"
```
</details>

### API information

<details>
<summary>1. Register Game Session</summary>

- **Endpoint**: `POST https://localhost:8000/api/game/register-game-session/`
- **Purpose**: Register a game session once it is completed.
- **Request Example**:
    ```json
    {   
        "session" : {
            "mode" : "VS"
        },
        "players" : [
            {
                "user" : "6bef40ed-dcc6-4b96-bd2b-40f7b82e1c14",
                "alias" : "registered player 1"
            },
            {
                "user" : "92f5f052-f23f-4fc7-9543-f9e29941de02",
                "alias" : "registered player 2"
            },
            {
                "alias" : "invited player 1"
            }
        ],
        "winner_alias" : "invited player 1",
        "start_date" : "10/10/2024 13:20:26"
    }
    ```
- **Remarks**:
    - Required fields: `session`, `mode`, `players`, `alias`, `winner_alias`, `start_date`
    - Not required: `user` (if omitted, the player is considered invited)
- **Permissions**: NoAuth, AllowAny
- **Response**:
    - Success (`HTTP_201_CREATED`):
        - If the winner is a registered user:
            ```json
            {
                "session_id": "2fb3affd-e45b-48cb-add5-76c8b83ac27f",
                "winner_id": "fc9c745a-8fd5-4c2f-979c-cfcc4d8f7399"
            }
            ```
        - If the winner is an invited user:
            ```json
            {
                "session_id": "7ed64343-c107-415b-8c26-c257e1a5c5b7",
                "winner_id": null
            }
            ```
    - Errors (`HTTP_400_BAD_REQUEST`):
        ```json
        {
            "session": [
                "This field is required."
            ]
        }
        ```
</details>

<details>
<summary>2. Show Current User Stats</summary>

- **Endpoint**: `GET https://localhost:8000/api/game/show-current-user-stats/`
- **Purpose**: Display the statistics for the current user.
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Response**:
    - Success (`HTTP_200_OK`):
        ```json
        {
            "total_games_played": 2,
            "total_games_won": 1,
            "versus_played": 2,
            "versus_won": 1,
            "tournament_played": 0,
            "tournament_won": 0,
            "last_man_standing_played": 0,
            "last_man_standing_won": 0,
            "brick_breaker_played": 0,
            "brick_breaker_won": 0
        }
        ```
    - Unauthorized (`HTTP_401_UNAUTHORIZED`):
        ```json
        {
            "detail": "User is inactive",
            "code": "user_inactive"
        }
        ```
</details>

<details>
<summary>3. Show Other User Stats</summary>

- **Endpoint**: `POST https://localhost:8000/api/game/show-other-user-stats/`
- **Purpose**: Display the statistics for another user.
- **Request Example**:
    ```json
    {
        "user_id": "380fdf46-eee6-4567-89e1-c5bedde376a4"
    }
    ```
- **Permissions**: NoAuth, ALLOW_ANY
- **Response**:
    - Success (`HTTP_200_OK`):
        ```json
        {
            "username": "user3",
            "total_games_played": 0,
            "total_games_won": 0,
            "versus_played": 0,
            "versus_won": 0,
            "tournament_played": 0,
            "tournament_won": 0,
            "last_man_standing_played": 0,
            "last_man_standing_won": 0,
            "brick_breaker_played": 0,
            "brick_breaker_won": 0
        }
        ```
    - Errors (`HTTP_400_BAD_REQUEST`, `HTTP_404_NOT_FOUND`):
        ```json
        {
            "error": "User not found."
        }
        ```
</details>

<details>
<summary>4. Show Current User Match History</summary>

- **Endpoint**: `GET https://localhost:8000/api/game/show-current-user-match-history/`
- **Purpose**: Display the match history for the current user.
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Response**:
    - Success (`HTTP_200_OK`):
        ```json
        [
            {
                "mode": "VS",
                "date_played": "10 Oct 2024",
                "duration": "1 d, 5 hrs 10 min 58 sec",
                "alias": "registered player 2",
                "number_of_players": 3,
                "result": "win"
            }
        ]
        ```
</details>

<details>
<summary>5. Show Other User Match History</summary>

- **Endpoint**: `POST https://localhost:8000/api/game/show-other-user-match-history/`
- **Purpose**: Display the match history for another user (friend only).
- **Request Example**:
    ```json
    {
        "user_id": "380fdf46-eee6-4567-89e1-c5bedde376a4"
    }
    ```
- **Permissions**: Bearer Token, IS_AUTHENTICATED
- **Response**:
    - Success (`HTTP_200_OK`):
        ```json
        [
            {
                "mode": "VS",
                "date_played": "10 Oct 2024",
                "duration": "1 d, 5 hrs 10 min 58 sec",
                "alias": "registered player 1",
                "number_of_players": 3,
                "result": "lost"
            }
        ]
        ```
    - Unauthorized (`HTTP_401_UNAUTHORIZED`):
        ```json
        {
            "error": "User is not your friend."
        }
        ```
</details>

<details>
<summary>6. Show All Games History</summary>

- **Endpoint**: `GET https://localhost:8000/api/game/show-all-games-history/`
- **Purpose**: Display the entire game history (public information).
- **Permissions**: NoAuth, ALLOW_ANY
- **Response**:
    - Success (`HTTP_200_OK`):
        ```json
        [
            {
                "mode": "VS",
                "date_played": "10 Oct 2024",
                "game_duration": "1 d, 5 hrs 10 min 32 sec",
                "number_of_players": 3,
                "winner_alias": "alias of registered player 2",
                "winner_username": "deactivated user"
            }
        ]
        ```
</details>
