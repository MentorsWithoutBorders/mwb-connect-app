# MWB Connect app
This mobile app allows us to connect mentors with students from our <a href="https://www.mentorswithoutborders.net/partners.php" target="_blank">partner NGOs</a> for one-off lessons.

The architecture is similar to the one from this <a href="https://medium.com/flutter-community/flutter-firebase-realtime-database-crud-operations-using-provider-c242a01f6a10" target="_blank">tutorial</a>. 

Running the app in:
* VS Code: https://flutter.dev/docs/development/tools/vs-code
* Android Studio and IntelliJ: https://flutter.dev/docs/development/tools/android-studio

### Description
The MWB Connect mobile app will facilitate the connections between passionate professionals from various fields and underprivileged students served by MWB’s <a href="https://www.mentorswithoutborders.net/partners.php" target="_blank">partner NGOs</a>.
The app is built with Flutter and uses Firestore on the backend. The way it should work is as follows:
<ol>
<li>The users (mentors and students) can create accounts and log in with their email addresses.</li>
<li>In order to be able to use the app, they have to appear in the lists of students sent by our partner NGOs or in the lists of employees-mentors from our partner companies.</li>
<li>The mentors can add/update the following details in their profiles:</li>
<ol>
<li>Field/subfield that they are specialized in (e.g. Programming/Machine Learning).</li>
<li>Availability for doing 1h-2h lessons with their students (e.g. Wednesday 8pm-10pm, Saturday 3pm-7pm and Sunday 10am-2pm).</li>
<li>Available/unavailable toggle.</li>
<li>How many lessons they want to do per week, month, or year.</li>
<li>The minimum interval between the lessons.</li>
</ol>
<li>The students can add/update the following details in their profiles:</li>
<ol>
<li>Full name</li>
<li>Availability for doing 1h-2h lessons with their mentors (e.g. Wednesday 8pm-10pm, Saturday 3pm-7pm and Sunday 10am-2pm).</li>
</ol>
<li>The students have to set clear goals for themselves (e.g. “I want to land my first job as a web developer”) and in order to be able to book the next lesson with a mentor, they have to write at least one new idea of their own for achieving their goals and they also have to solve a quiz related to the mental process goal/steps, relaxation method or super-focus method that are part of the MWB training.</li>
<li>The mentors can accept or reject the request for doing a lesson. If they accept, they will have to send a Google Meet link to their students.</li>
</ol>