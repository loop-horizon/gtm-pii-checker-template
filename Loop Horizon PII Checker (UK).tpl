___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Loop Horizon PII Checker (UK)",
  "description": "Aims to locate email, phone and postcode (UK format) within the variable passed and replace with a static value, as an analysis aid to help locate PII issues and resolve them correctly.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "variableToCheck",
    "displayName": "Variable to check",
    "simpleValueType": true,
    "help": "Add the variable here that you would like to check for PII.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "group1",
    "displayName": "Multi-value string?",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "checkbox1",
        "checkboxText": "Multi-value string?",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "delimiter",
        "displayName": "Primary delimiter",
        "simpleValueType": true,
        "help": "The tool can handle two delimiters so, for example: for a URL (with potential delimiters of \".\", \"-\", \"/\",  \"?\", \"\u003d\" and so on), use separate variables splitting the URL into different parts for assessment (e.g. hostname, pathname and query parameters). For pathname, you could use \u0027/\u0027 as the primary delimiter, and for query parameters, you could use \u0027\u0026\u0027 as the primary delimiter, and so on.",
        "valueHint": "example: \u0026"
      },
      {
        "type": "TEXT",
        "name": "delimiter1",
        "displayName": "Secondary delimiter",
        "simpleValueType": true,
        "help": "\u003cp\u003eThe tool can handle two delimiters, for example: for URL query parameters, the primary delimiter may be \"\u0026\", and the secondary delimiter may be \"\u003d\". The final value after the delimiter will be the one assessed for PII: for example, a query parameter of \"some\u003dvalue\", with a \"\u003d\" delimiter, would only assess \"value\" for PII, not \"some\".\u003c/p\u003e\u003cp\u003e\u003cstrong\u003eNote:\u003c/strong\u003e there should only be one secondary delimiter per value or you will not get the expected result (so \"something\u003dsomething\", not \"something\u003dsome\u003dthing\" - the second input will not work).\u003c/p\u003e",
        "valueHint": "example: \u003d"
      }
    ],
    "help": "Are you passing a string that has more than one value to be assessed? For example: a string with multiple query parameters."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Enter your template code here.
const decodeUriComponent = require('decodeUriComponent');
const delimiter = data.delimiter;
const delimiter1 = data.delimiter1;
const removeSpaces = function (str) {
    var result = '';
    for (var i = 0; i < str.length; i++) {
      if (str[i] !== ' ' && str[i] !== '\t' && str[i] !== '\n') {
        result += str[i];
      }
    }
    return result;
};
const removeHyphensEtAl = function (str) {
    // Remove any spaces, hyphens, or parentheses for easier processing
    var result = '';
    for (var i = 0; i < str.length; i++) {
    if (str[i] !== ' ' && str[i] !== '\t' && str[i] !== '\n' && str[i] !== '-' && str[i] !== '(' && str[i] !== ')' && str[i] !== '[' && str[i] !== ']' && str[i] !== '.' && str[i] !== ',' && str[i] !== '_') {
      result += str[i];
    }
  }
  return result;
};


const isValidEmail = function(input) {
    // Check for the presence of '@' and '.'
    var atSymbol = input.indexOf('@');
    var dot = input.lastIndexOf('.');
    
    // Check that '@' and '.' are present and in the correct order
    if (atSymbol < 1 || dot <= atSymbol + 1 || dot === input.length - 1) {
      return false;
    }
    
    // Check that there are no spaces before '@'
    var beforeAt = input.substring(0, atSymbol);
    if (beforeAt.indexOf(' ') !== -1) {
      return false;
    }
    
    // Check that there are no spaces after '@' and before '.'
    var betweenAtAndDot = input.substring(atSymbol + 1, dot);
    if (betweenAtAndDot.indexOf(' ') !== -1) {
      return false;
    }
    
    // Check that there are no spaces after '.'
    var afterDot = input.substring(dot + 1);
    if (afterDot.indexOf(' ') !== -1) {
      return false;
    }
    
    // If all checks pass, the input is likely a valid email
    return true;
};
const isValidPhoneNumber = function (input) {
    //remove hypens, spaces, and parentheses and so on
    var phoneNumber = removeHyphensEtAl(input);
    // Check for the UK country code or leading zero
    var startsWithCountryCode = phoneNumber.indexOf('+44') === 0;
    var startsWithZero = phoneNumber.indexOf('0') === 0;
    if (!startsWithCountryCode && !startsWithZero) {
      return false;
    }
  
    // Remove the country code or leading zero for further checks
    if (startsWithCountryCode) {
      phoneNumber = phoneNumber.substring(3);
    } else if (startsWithZero) {
      phoneNumber = phoneNumber.substring(1);
    }
  
    // Check the length of the remaining phone number
    /*
    Note: if the phone number sits within a larger string it will not get matched because length of string is a deciding factor
    We would not want to match against legitimate identifiers for example
    */
    var isLengthValid = phoneNumber.length === 10 || phoneNumber.length === 9;
    if (!isLengthValid) {
      return false;
    }
  
    // Check that all remaining characters are digits
    for (var j = 0; j < phoneNumber.length; j++) {
      if (phoneNumber[j] < '0' || phoneNumber[j] > '9') {
        return false;
      }
    }
  
    // If all checks pass, the input is likely a valid phone number
    return true;
};
const isValidPostcode = function (input) {
    // Convert input to uppercase for case-insensitive comparison
    var postcode = removeSpaces(input.toUpperCase());
  
    // Check for special case 'GIR 0AA'
    if (postcode === 'GIR0AA') {
      return true;
    }
  
    // Validate the length of the postcode
    /*
    Note: if the postcode number sits within a larger string it will not get matched because length of string is a deciding factor
    We would not want to match against legitimate identifiers for example
    */
    if (postcode.length < 5 || postcode.length > 7) {
      return false;
    }
  
    // Validate area (first letter)
    var area = postcode.charAt(0);
    if (area < 'A' || area > 'Z' || area === 'I' || area === 'Z') {
      return false;
    }
  
    // Validate district (second character, alphanumeric)
    var districtSecondChar = postcode.charAt(1);
    if ((districtSecondChar < '0' || districtSecondChar > '9') && 
        (districtSecondChar < 'A' || districtSecondChar > 'Z')) {
      return false;
    }
  
    // Validate optional district third character (alphanumeric)
    var districtThirdChar = postcode.charAt(2);
    if (districtThirdChar && districtThirdChar !== '0' && 
        (districtThirdChar < 'A' || districtThirdChar > 'Z') && 
        (districtThirdChar < '0' || districtThirdChar > '9')) {
      return false;
    }
  
    // Validate sector (one digit before the space)
    var sectorIndex = postcode.length - 3;
    var sector = postcode.charAt(sectorIndex);
    if (sector < '0' || sector > '9') {
      return false;
    }
  
    // Validate unit (last two letters)
    var unitFirstChar = postcode.charAt(postcode.length - 2);
    var unitSecondChar = postcode.charAt(postcode.length - 1);
    if ((unitFirstChar < 'A' || unitFirstChar > 'Z') || 
        (unitSecondChar < 'A' || unitSecondChar > 'Z')) {
      return false;
    }
  
    // If all checks pass, the input is likely a valid postcode
    return true;
};

if(data.variableToCheck){
  //set the values required - the need to be able to be overwritten
  let originalValue = data.variableToCheck;
  
  //fix broken values so you don't get JS errors
  if(originalValue === undefined){originalValue = '';}
  if(originalValue === null){originalValue = '';}
  originalValue = decodeUriComponent(originalValue);

  if(data.checkbox1){
    if(delimiter1){
      //if the secondary delimiter is populated, asses the final value returned from the split - query parameters are the primary example
      let splitOriginalValue = originalValue.split(delimiter).map(function(key){return {
        'key': key.split(delimiter1)[0], 'value': key.split(delimiter1)[key.split(delimiter1).length -1]
      };});
      var checkedValues = splitOriginalValue.map(function(key){
        if(isValidEmail(key.value)){
            let returnVal = '';
            key.key === key.value ? returnVal = 'pii_em' : returnVal = key.key + delimiter1 + 'pii_em';
            return returnVal;
        }
        //check if it is a phone number
        else if(isValidPhoneNumber(key.value)){
          let returnVal = '';
          key.key === key.value ? returnVal = 'pii_tel' : returnVal = key.key + delimiter1 + 'pii_tel';
          return returnVal;
        }
        //check if it is a postcode
        else if(isValidPostcode(key.value)){
          let returnVal = '';
          key.key === key.value ? returnVal = 'pii_post' : returnVal = key.key + delimiter1 + 'pii_post';
          return returnVal;
        }
        else {
          let returnVal = '';
          key.key === key.value ? returnVal = key.value : returnVal = key.key + delimiter1 + key.value;
          return returnVal;  
        }
    });
    } else {
        //else it's likely a list of values separated by the delimiter so no need to split twice
        let splitOriginalValue = originalValue.split(delimiter);
        var checkedValues = splitOriginalValue.map(function(key){
          if(isValidEmail(key)){
              return 'pii_em';
          }
          //check if it is a phone number
          else if(isValidPhoneNumber(key)){
              return 'pii_tel';
          }
          //check if it is a postcode
          else if(isValidPostcode(key)){
              return 'pii_post';
          }
          else {
              return key;
          }
      });
    }
    originalValue = checkedValues.join(delimiter);
  } else {
    //check if it is an email
    if(isValidEmail(originalValue)){
      originalValue = 'pii_em';
    }
    //check if it is a phone number
    else if(isValidPhoneNumber(originalValue)){
      originalValue = 'pii_tel';
    }
    //check if it is a postcode
    else if(isValidPostcode(originalValue)){
      originalValue = 'pii_post';
    }
  }
  return originalValue;
}
else {
  return 'pii_err';
}


___TESTS___

scenarios:
- name: Single PII val - phone
  code: |-
    const mockData = '07901234567';
    const mockCheckBox = false;
    const mockDelimiter = '&';
    const mockDelimiter1 = '=';

    // Call runCode to run the template's code.
    let variableResult = runCode({variableToCheck: mockData, checkbox1: mockCheckBox, delimiter: mockDelimiter, delimiter1: mockDelimiter1});

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Single PII val - email
  code: |-
    const mockData = 'some@pii.value';
    const mockCheckBox = false;
    const mockDelimiter = '&';
    const mockDelimiter1 = '=';

    // Call runCode to run the template's code.
    let variableResult = runCode({variableToCheck: mockData, checkbox1: mockCheckBox, delimiter: mockDelimiter, delimiter1: mockDelimiter1});

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Single PII val - postcode
  code: |-
    const mockData = 'HE0 1LO';
    const mockCheckBox = false;
    const mockDelimiter = '&';
    const mockDelimiter1 = '=';

    // Call runCode to run the template's code.
    let variableResult = runCode({variableToCheck: mockData, checkbox1: mockCheckBox, delimiter: mockDelimiter, delimiter1: mockDelimiter1});

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Multi-value - query perams with / without delimiters
  code: |-
    const mockData = '07901234567&em=some@pii.value&po=HE0 1LO&tid=ab12cd34';
    const mockCheckBox = true;
    const mockDelimiter = '&';
    const mockDelimiter1 = '=';

    // Call runCode to run the template's code.
    let variableResult = runCode({variableToCheck: mockData, checkbox1: mockCheckBox, delimiter: mockDelimiter, delimiter1: mockDelimiter1});

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Multi-value - list of values
  code: |-
    const mockData = 'something+hello+07901234567+something_HE0 1LO';
    const mockCheckBox = true;
    const mockDelimiter = '+';
    const mockDelimiter1 = '_';

    // Call runCode to run the template's code.
    let variableResult = runCode({variableToCheck: mockData, checkbox1: mockCheckBox, delimiter: mockDelimiter, delimiter1: mockDelimiter1});

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Example where it cannot find PII
  code: |-
    /*
    The values are in the middle of a string, so it cannot recognise them as PII as "lenght" is a defining factor
    */
    const mockData = 'https://www.something07901234567HE0%201L0something.com';
    const mockCheckBox = true;
    const mockDelimiter = '.';
    const mockDelimiter1 = '/';

    // Call runCode to run the template's code.
    let variableResult = runCode({variableToCheck: mockData, checkbox1: mockCheckBox, delimiter: mockDelimiter, delimiter1: mockDelimiter1});

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Example where it may break a value
  code: |-
    /*
    There is more than one secondary delimiter - when the secondary delimiter is used, the code will only check the first and last values from thew split (so the PII is - entirely accidentally - removed but this is not the intention).
    */
    const mockData = 'https://www.something_07901234567_HE0%201L0_else.com';
    const mockCheckBox = true;
    const mockDelimiter = '.';
    const mockDelimiter1 = '_';

    // Call runCode to run the template's code.
    let variableResult = runCode({variableToCheck: mockData, checkbox1: mockCheckBox, delimiter: mockDelimiter, delimiter1: mockDelimiter1});

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);


___NOTES___

Created on 13/06/2024, 16:07:32


