# UMAI ROR ASSESSMENT

> Prerequisites needed to run the project

- Ruby Language
- MySQL Installation

> Versions Needed

- Ruby Version Used = 3.3.0, but it can be executable with any ruby version >= than 3.0.0
- Any Mysql Version Installation

> To Execute the project, please clone the repository and in the local directory, type 

- `ruby app.rb`

> Note: One dependency to run the project is to have the local installation of mysql without any password, so if you have any password, please temporarily remove it!

After this you are good to go!

Postman Collection Link

https://documenter.getpostman.com/view/8201672/2sA35EaicD

> Approach I followed and my thinking process:

- I used the system commands directly to execute the mysql commands to interact with the database,
The reason I chose this approach is because of it's independent behaviour! So we are not dependent on any mysql version or any gem installation.
- I used the default minitest library for writing the test cases.
- I used the bulk insertion approach to insert the seeds.
- I used the ruby background process to execute the Worker.
