# SaltedPasswordDecryption
This POSTGRESQL table and functions were built in order to create password dictionary for one way hashed passwords. Initialy to decrypt OpenCart hashed passwords.

# In order to execute this follow these points:
1) Install Postgersql 9.5 or higher from: https://www.postgresql.org/
2) Create a new DB. (whatever name you want).
3) Open the SQL execution window and copy paste the "db.sql" file.
4) Find a password dictionary and make sure it is in the text format of `'pass1','pass2','pass3'...` and so on.
5) Open a new SQL execution window and insert the password dictionary into the DB with the desired salt (for example: `select * from insertPassword(array['password','123456','demo']::TEXT[], 'GyJjOsxQt');` After a successful execution the returned value should be `Finished`.
6) Find out if you have a match with the salted "Hashed Password" by opening a new SQL execution window and executing the stored prcedure with the hashed password you have and the salt, for example: `select * from findMatch('1b976f73f9b05a7b789d1df9f67e709b01ebaed8', 'GyJjOsxQt');` This example of a password 'demo' hashed by SHA1 in the OpenCart user platform.


# Contact
For any request or question contact me at:
whiteHatDude1@gmail.com
