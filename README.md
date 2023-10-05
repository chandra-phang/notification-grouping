## Take-home Assignment

The following scenarios are common on client platform.
- User post an answer to a question, questioner and other answerers receive notification
- User post a comment on an answer, answerer and users who commented before receive notification
- User upvote an answer, answerer receive notification

Due to the different types of notification with different message templates, our engineers are tasked to implement the notification in a flexible way such that it can cater to new types of notification in future.

Your job is to design a solution that fulfills the following condition:

1. Notification should be sent to the right recipients except yourself. (e.g if questioner is same as answerer, notification should not be sent)
2. Notification must be merged if they are from the same question/answer. For example, user A posted a question and then user B, C answered the question respectively.
  - In this case, user A will get user B's notification.
  - After that user A gets user C's notification and user B also can get that one.
  - User A will see that the two notifications being merged into one notification. e.g '{2nd answerer name}, {1st answerer name} answered {questioner name}’s question, {question text}'
3. Notifications should be batched up to 3 notifications before sending or if the last notification(s) has not been send after 30 seconds.


Based on the scenario above, write a CLI that implements the function `getNotificationsForUser(notifications, user_id)` that will take an input json and prints out the solution. Each item in the array below represents a `Notification` entity, such that:

- **user_id**: The `User` that is receiving the notification.
- **notification_type_id**: The `NotificationType`, 1 for `Post Answer`, 2 for `Post Comment` and 3 for `Upvote Answer`
- **sender_id**: The `User` that triggers the notification.
- **sender_type**: For simplicity, all sender type are of the entity `User` (all actions are performed by users)
- **target_id**: The id of the entity that the sender acts upon. E.g. `target_id` of `100` means the sender performs an action on a `Question` with id of `100`.
- **target_type**: For simplicity, we assume all actions are taken on the type `Question`.
- **created_at**: The timestamp the action is triggered.

Given the following payload:

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
}, {
  "user_id": "hackamorevisiting",
  "notification_type_id": 3,
  "sender_id": "funeralpierce",
  "sender_type": "User",
  "target_id": 36,
  "target_type": "Question",
  "created_at": 1574325917276
}, {
  "user_id": "hackamorevisiting",
  "notification_type_id": 2,
  "sender_id": "backwarddusty",
  "sender_type": "User",
  "target_id": 46,
  "target_type": "Question",
  "created_at": 1574325959410
}, {
  "user_id": "hackamorevisiting",
  "notification_type_id": 2,
  "sender_id": "makerchorse",
  "sender_type": "User",
  "target_id": 95,
  "target_type": "Question",
  "created_at": 1574326028535
}]
```

When we call the program with the given input:

```bash
$ ruby notification.rb [inputFile] [user_id]
$ ruby notification.rb notifications.json hackamorevisiting

$ node notification.js [inputFile] [user_id]
$ node notification.js notifications.json hackamorevisiting
```

Then it should output the following:
```
[2019-11-21 16:45:03] gratuitystopper answered a questions
[2019-11-21 16:45:59] backwarddusty and makerchorse commented on a question
[2019-11-21 16:45:17] funeralpierce upvoted a question
[2019-11-21 16:47:08] makerchorse commented on a question
```

Your function should be runnable with the payload [notifications-1000.json], such that we can preview the notifications for different user.

Please include reasonable assumptions made if any. If anything is unclear, you may set a reasonable assumption and state it at the beginning of the submission. Including a test will be counted as a bonus.
