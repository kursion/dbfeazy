/**
 * Here is a small example of how to use it.
 * Don't forget to `npm install` in order to run the example.
 */

// NOTE: in your project you would use:
// const DBFeazy = requier("dbfeazy");
const DBFeazy = require("../");

const db = new DBFeazy("users"); // Opens user.dbf and user.op files
db.Restore(); // Restores previous state

// Adding some values
db.Add("kursion.age", 27);
db.Add("kursion.lang", "en");

// Adding an object
const nellyInfo = { age: 29, lang: "fr" };
db.Add("nelly", nellyInfo);

// Deleting something
db.Add("kursion.sex", "small");
db.Del("kursion.sex");

// Updating a value if its key exists
if (db.Exists("kursion.age")) {
  db.Add("kursion.age", 18);
}

// Getting a value
db.Get("nelly"); // {age: 45, lang: 'fr'}
db.Get("kursion.sex"); // undefined (since we deleted it)
db.Get("kursion.age"); // 27
db.Get("olivier.age"); // 45

/**
 * Save the DB
 * NOTE: until now every operations are stored in the
 * the operations file (check futher for more information)
 * and the memory.t@github.com:kursion/dbfeazy.gitu
 *
 * Since we finished to work on this database we can
 * store the current state of the database and clean
 * the operation file.
 */
db.Save();

/**
 * Now the operations file (users.op) should be cleaned and
 * the database object should be stored into the database
 * file (users.dbf) as a stringified JSON.
 */
