# kuber 0.2.3

* Save relevant gcloud information in hidden file
* Select image and cluster on the fly
* Authenticate cluster before running
* Use directory in kuber_pods() and kuber_kill()
* Documentation for sys() and todo()
* Tell user what to install on load

# kuber 0.2.2

* Documentation about exec.R debugging
* Use crayon for system calls
* Add todo to user tasks
* Handle system warnings

# kuber 0.2.1

* Internal refactoring of system commands
* Check if user has everything setup on load
* Project described in license
* If list.rds is missing, kuber_pods() still works
* kuber_push() cleans jobs/ folder
* Restart policy for pods
* Added folder option to kuber_list()

# kuber 0.2.0

* Ability to change bucket and image names
* Documented README.md
* Better names for the functions
* Cleaner exec.R template
* List file now called list.rds instead of ids.rds 
* Function to list objects in bucket
* Function to kill all jobs
* Prettier output for most functions

# kuber 0.1.2

* Password passed via askForPassword() in RStudio
* Code commented internaly
* Job expansion `for` syntax fixed
* Purrr removed from dependencies
* System calls' output displayed in console
* System calls' errors not silenced

# kuber 0.1.1

* Better authentication via JSON tokens
* Functions in utils.R are documented
* Main functions return paths insted of TRUE
* Docker authentication with gcloud
* Template function only edits exec.R

# kuber 0.1.0

* Working package
