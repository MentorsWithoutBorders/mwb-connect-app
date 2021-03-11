<div align = "center">

<h1><a href="https://www.mentorswithoutborders.net/">MWB Connect Mobile App</a></h1>

<a href="https://github.com/MentorsWithoutBorders/mwb_connect_app/blob/master/LICENSE">
<img alt="License" src="https://img.shields.io/github/license/MentorsWithoutBorders/mwb_connect_app?style=plastic&color=white&label=License"> </a>

<a href="https://github.com/MentorsWithoutBorders/mwb_connect_app/pulse">
<img alt="Updated" src="https://img.shields.io/github/last-commit/MentorsWithoutBorders/mwb_connect_app?style=plastic&color=e30724&label=Updated"> </a>

<a href="https://github.com/MentorsWithoutBorders/mwb_connect_app/stargazers">
<img alt="Stars" src="https://img.shields.io/github/stars/MentorsWithoutBorders/mwb_connect_app?style=plastic&color=00d451&label=Stars"></a>

<a href="https://github.com/MentorsWithoutBorders/mwb_connect_app/network/members">
<img alt="Forks" src="https://img.shields.io/github/forks/MentorsWithoutBorders/mwb_connect_app?style=plastic&color=1688f0&label=Forks"> </a>

<a href="https://github.com/MentorsWithoutBorders/mwb_connect_app/watchers">
<img alt="Watchers" src="https://img.shields.io/github/watchers/MentorsWithoutBorders/mwb_connect_app?style=plastic&color=ff5500&label=Watchers"> </a>

<a href="https://github.com/MentorsWithoutBorders/mwb_connect_app/graphs/contributors">
<img alt="Contributors" src="https://img.shields.io/github/contributors/MentorsWithoutBorders/mwb_connect_app?style=plastic&color=f0f&label=Contributors"> </a>

<!-- <h2>Connecting mentors with mentees</h2>

<figure>
  <img src= "https://raw.githubusercontent.com/MentorsWithoutBorders/mwb_connect_app/master/images/screenshot.jpg" alt="MWB Connect App Screenshot" style="width:100%">
  <figcaption>MWB Connect App Screenshot</figcaption>
</figure> -->

</div>

This mobile app allows us to connect mentors with students from our partner NGOs (https://www.mentorswithoutborders.net/partners.php) for one-off lessons.
This mobile app allows us to connect mentors with students from our <a href="https://www.mentorswithoutborders.net/partners.php" target="_blank">partner NGOs</a> for one-off lessons.

The architecture is similar to the one from this <a href="https://medium.com/flutter-community/flutter-firebase-realtime-database-crud-operations-using-provider-c242a01f6a10" target="_blank">tutorial</a>.

Running the app in:

- VS Code: https://flutter.dev/docs/development/tools/vs-code
- Android Studio and IntelliJ: https://flutter.dev/docs/development/tools/android-studio

### Details

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
