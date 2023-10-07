# Coding Challenge: Notification Grouping

## Task Guidelines
Addressing common scenarios on a client platform involving notifications:
- User posts an answer to a question: Questioner and other answerers receive a notification.
- User posts a comment on an answer: Answerer and users who commented before receive a notification.
- User upvotes an answer: Answerer receives a notification.

To accommodate future notification types with different message templates, design a flexible solution.

### Conditions:
1. Notifications should be sent to the right recipients, excluding the sender.
2. Notifications must be merged if they are from the same question/answer.
3. Batch notifications up to 3 before sending or if the last notification(s) hasn't been sent after 30 seconds.

### CLI Implementation:
Create a CLI with a function `getNotificationsForUser(notifications, user_id)` that takes input JSON and prints the solution.

### Notification Entity:
- **user_id**: Receiving user's ID.
- **notification_type_id**: Notification type (1 for Post Answer, 2 for Post Comment, 3 for Upvote Answer).
- **sender_id**: ID of the user triggering the notification.
- **sender_type**: Sender type (User).
- **target_id**: ID of the entity the sender acts upon (e.g., Question).
- **target_type**: Type of the entity (Question).
- **created_at**: Timestamp when the action is triggered.

### Example Input:

```json
[{
  "user_id": "hackamorevisiting",
  "notification_type_id": 2,
  "sender_id": "makerchorse",
  "sender_type": "User",
  "target_id": 46,
  "target_type": "Question",
  "created_at": 1574325866040
}, {
  "user_id": "hackamorevisiting",
  "notification_type_id": 1,
  "sender_id": "gratuitystopper",
  "sender_type": "User",
  "target_id": 37,
  "target_type": "Question",
  "created_at": 1574325903935
},
...
]
```

### CLI Usage:

```bash
$ ruby notification.rb [inputFile] [user_id]
$ ruby notification.rb notifications.json hackamorevisiting
```

### Expected Output:

```
[2019-11-21 16:45:03] gratuitystopper answered a question
[2019-11-21 16:45:59] backwarddusty and makerchorse commented on a question
[2019-11-21 16:45:17] funeralpierce upvoted a question
[2019-11-21 16:47:08] makerchorse commented on a question
```
