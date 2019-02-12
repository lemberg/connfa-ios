const functions = require('firebase-functions');
const admin = require('firebase-admin');
const gcs = require('@google-cloud/storage')();

admin.initializeApp(functions.config().firebase);

const ref = admin.database().ref();

const availablePins = '/availablePins/';
const pins = '/pins/';
const unspecifiedUsers = '/unspecifiedUsers/';

var countOfPINDigits = 4

exports.anonimusUserEnter = functions.auth.user().onCreate(event => {
    const user = event.data;
    console.log("Anonimus user detected!: " + user.uid);
    generateUnquePIN(user.uid);
    return event;
});

exports.syncFilePaths = functions.storage.object().onChange(event => {
    const object = event.data;   
    const filePath = object.name;
    const fileId = filePath.replace('.','');
    console.log(filePath);
    if (object.resourceState === 'not_exists') {
        console.log("Delete file path");
        ref.child(fileId).set(null);
    } else {
        console.log("Add file path");        
        ref.child(fileId).set(filePath);
    }
});

function generateUnquePIN(userID) {
    ref.child(availablePins).limitToLast(1).once("value", function (snapshot) {
        if (snapshot.numChildren() > 0) {
            var pinKey = Object.keys(snapshot.val())[0]; //19 in case of 19:3
            var pinValue = snapshot.val()[pinKey]; //3 in case of 19:3

            console.log("new pin for KEY = " + pinKey + ' VALUE = ' + pinValue);
            ref.child(availablePins + pinKey).remove();
            saveGeneratedPIN(userID, pinValue);

            if (pinKey.toString() === '0') {
                console.log("POOL IS EMPTY");
                let digitsCount = pinValue.toString().length + 1;
                processInCaseOfEmptyPINsPool(digitsCount);
            }
        } else {
            //TODO: need catch error
            console.log("POOL IS EMPTY");
            processInCaseOfEmptyPINsPool();
            processUserWithoutPin(userID);
        }
    }).catch(function (reason) {
        console.log("PROBLEM! " + reason);
        processUserWithUnspecifiedError(userID, reason);
    })
}

function processInCaseOfEmptyPINsPool(digitsCount = countOfPINDigits) {
    countOfPINDigits = digitsCount
    generatePinsArray(countOfPINDigits)
}

function saveGeneratedPIN(userID, pin) {
    ref.child(pins).child(pin).set(true);

    const userRef = ref.child('/users/' + userID);
    userRef.set({
        ownPin: pin
    });
    console.log("Aninumus user " + userID + " registered with pin = " + pin);
}

/**
 *  DATA GENERATOR SECTION
 */
exports.pinsDataGenerator = functions.https.onRequest((request, response) => {
    response.send("{ Generating! }");
    generatePinsArray();
});

function saveGeneratedPINsDataToDB(dataArray) {
    dataArray.forEach(function (pin, i) {
        ref.child(availablePins + i).set(pin);
    });
}

/**
 *
 */
function generatePinsArray() {
    let arrayCount = Math.pow(10, countOfPINDigits);
    var numbers = Array(arrayCount).fill().map((e, i) => formatDigit(i + 1));
    shuffleArray(numbers);
    console.log("CONGRATS!");
    saveGeneratedPINsDataToDB(numbers);
}

/**
 * Shuffle array in random way
 */
function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        let j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
}

/**
 * FORMAT Int to 4-Digits String
 */
function formatDigit(num, n = countOfPINDigits) {
    digit = '';
    if (typeof n === 'undefined' || num.toString().length === 4)
        return num.toString();
    for (i = 1; i < n; i++) {
        if (num < (1 + Array(i + 1).join("0")))
            digit += '0';
    }
    digit = digit + num;
    return digit;
}

/**
 * In case of: 'The error occurs. PIN is not generated.'
 */
function processUserWithoutPin(userID) {
    let UserWithoutPinErrorCode = "404/";
    const noPinError = "PIN is not specified cause pool is empty!";
    ref.child(unspecifiedUsers + UserWithoutPinErrorCode + userID).set(noPinError);
}

/**
 * In case of: 'The error occurs. Internal server error.'
 */
function processUserWithUnspecifiedError(userID, errorReason) {
    let UserWithoutPinErrorCode = "500/";
    ref.child(unspecifiedUsers + UserWithoutPinErrorCode + userID).set(errorReason);
}