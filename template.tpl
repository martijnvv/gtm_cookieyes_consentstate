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
  "displayName": "CookieYes - Consent State",
  "categories": [
    "ADVERTISING",
    "ANALYTICS",
    "MARKETING"
  ],
  "description": "Returns the CookieYes consent groups. Can be used with setting up triggers for tags.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "LABEL",
    "name": "label1",
    "displayName": "This variable returns the consent groups accepted by the visitor to be used with tag triggers, for example."
  },
  {
    "type": "RADIO",
    "name": "returnType",
    "displayName": "Return type",
    "radioItems": [
      {
        "value": "all",
        "displayValue": "All consent groups"
      },
      {
        "value": "selected",
        "displayValue": "Selected consent group\u0027s status",
        "subParams": [
          {
            "type": "SELECT",
            "name": "selectedGroup",
            "displayName": "",
            "macrosInSelect": true,
            "selectItems": [
              {
                "value": "necessary",
                "displayValue": "necessary"
              },
              {
                "value": "functional",
                "displayValue": "functional"
              },
              {
                "value": "analytics",
                "displayValue": "analytics"
              },
              {
                "value": "performance",
                "displayValue": "performance"
              },
              {
                "value": "advertisement",
                "displayValue": "advertisement"
              },
              {
                "value": "other",
                "displayValue": "other"
              }
            ],
            "simpleValueType": true
          },
          {
            "type": "RADIO",
            "name": "individualConsentOutput",
            "displayName": "Return consent group status as",
            "radioItems": [
              {
                "value": "true_false",
                "displayValue": "\"false\" / \"true\"",
                "help": "Default \"true\" or \"false\""
              },
              {
                "value": "consent_mode",
                "displayValue": "\"denied\" / \"granted\"",
                "help": "GTM Consent Mode format"
              }
            ],
            "simpleValueType": true
          }
        ],
        "help": "Select an individual consent group to return its status as \"true\" or \"false\"."
      }
    ],
    "simpleValueType": true,
    "help": "Return either a list of all consent groups with their statuses or the status of an individual group. Default all.",
    "defaultValue": "all"
  },
  {
    "type": "RADIO",
    "name": "outputType",
    "displayName": "Variable Output Type",
    "radioItems": [
      {
        "value": "string",
        "displayValue": "String"
      },
      {
        "value": "array",
        "displayValue": "Array"
      }
    ],
    "simpleValueType": true,
    "help": "The output of the variable is a list of accepted consent groups. It can be returned either as a JS array or a comma joined string.",
    "enablingConditions": [
      {
        "paramName": "returnType",
        "paramValue": "all",
        "type": "EQUALS"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

/*
This template returns the consent groups that the visitor has selected.
It reads the cookie (cookieyes-consent) set by CookieYes and also checks the dataLayer messages.
There is also a possibility to set default consent groups for situation where the dataLayer
or cookie information is not yet available.

Template by Martijn van Vreeden, based on the work of Taneli Salonen.
*/

const log = require('logToConsole');
const getCookieValues = require('getCookieValues');
const copyFromWindow = require('copyFromWindow');


// return the value based on the selections in the template
function returnVariableValue(value) {
  const individualConsentReturnVal = {
    'true': data.individualConsentOutput === 'consent_mode' ? 'granted' : 'true',
    'false': data.individualConsentOutput === 'consent_mode' ? 'denied' : 'false'
  };
  
  // return only the selected groups status
  if (data.returnType === 'selected') {
    return value.filter(v => {
      return v.split(':')[0] === data.selectedGroup;
    }).length > 0 ? individualConsentReturnVal['true'] : individualConsentReturnVal['false'];
  }
  
  // return the full list as a string
  if (data.outputType === 'string') {
    return value.join(',');
  }
  
  // return the full list as an array
  return value;
}


// get the cookie values
const consentCookie = getCookieValues('cookieyes-consent', true)[0];
if (typeof consentCookie === 'string' && consentCookie.indexOf('consentid:') > -1) {
  const groupsPart = consentCookie.split(",").filter(function(keyval) {
    // All of these are used to store consent information
    return keyval.indexOf("necessary:") === 0 || keyval.indexOf("functional:") === 0 || keyval.indexOf("analytics:") === 0 || keyval.indexOf("performance:") === 0 || keyval.indexOf("advertisement:") === 0 || keyval.indexOf("other:") === 0;
  });
  log(groupsPart);
  if (groupsPart.length > 0) {
    // join all consent data into one string
    const allGroups = groupsPart.map(part => {
      const groupData = part.split(",");
      return groupData[0] ? groupData[0] : '';
    }).join(',');
    log(allGroups);
    
    const consentGroupsArr = allGroups ? allGroups.split(",") : null;
    log(consentGroupsArr);

    if (consentGroupsArr) {
      const consentGroups = consentGroupsArr.filter(function(group) {
         return group.split(':')[1] === 'yes';
      });
      if (consentGroups.length > 0) {
        return returnVariableValue(consentGroups);
      }
    }
    
  }
}

// as a fallback, if neither the cookie nor dataLayer exist, return default consent groups listed in the template
// this can be the case when a new visitor has entered the site and OneTrust hasn't yet pushed the dataLayer message
const defaultGroups = data.defaultGroups;
if (defaultGroups && defaultGroups.length > 0) {
  const consentGroups = defaultGroups.map(function(group) {
    return group.group.split(':')[0] + ':yes';
  });
  log(consentGroups);
  return returnVariableValue(consentGroups);
}

return returnVariableValue([]);


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "cookieyes-consent"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "OptanonActiveGroups"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "OnetrustActiveGroups"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: global variable is available
  code: |-
    const mockData = {
      outputType: 'string'
    };

    const log = require('logToConsole');

    mock('copyFromWindow', (varName) => {
      return ",1,2,3";
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = "1:1,2:1,3:1";

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
- name: dataLayer is available
  code: |-
    const mockData = {
      outputType: 'string'
    };

    const log = require('logToConsole');

    mock('copyFromDataLayer', (dlName) => {
      return ",1,2,3";
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = "1:1,2:1,3:1";

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
- name: cookie data available, no global variable
  code: |-
    const mockData = {
      outputType: 'string'
    };

    const log = require('logToConsole');

    mock('copyFromWindow', (varName) => {
      return undefined;
    });

    mock('getCookieValues', (cookieName, decode) => {
      return ['isIABGlobal=false&datestamp=Mon+Aug+09+2021+08:27:26+GMT+0300+(Eastern+European+Summer+Time)&version=6.21.0&landingPath=NotLandingPage&groups=1:1,2:1'];
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = "1:1,2:1";

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
- name: cookie data available, no dataLayer
  code: |-
    const mockData = {
      outputType: 'string'
    };

    const log = require('logToConsole');

    mock('copyFromDataLayer', (dlName) => {
      return undefined;
    });

    mock('getCookieValues', (cookieName, decode) => {
      return ['isIABGlobal=false&datestamp=Mon+Aug+09+2021+08:27:26+GMT+0300+(Eastern+European+Summer+Time)&version=6.21.0&landingPath=NotLandingPage&groups=1:1,2:1'];
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = "1:1,2:1";

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
- name: no global variable, no dl, no cookie, only default fallback
  code: |-
    const mockData = {
      outputType: 'string',
      defaultGroups: [{group: '1'}]
    };

    const log = require('logToConsole');

    mock('copyFromWindow', (varName) => {
      return undefined;
    });

    mock('copyFromDataLayer', (dlName) => {
      return undefined;
    });

    mock('getCookieValues', (cookieName, decode) => {
      return [];
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = "1:1";

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
- name: no global variable, no dl, no cookie, no default fallback
  code: |-
    const mockData = {
      outputType: 'string'
    };

    const log = require('logToConsole');

    mock('copyFromWindow', (varName) => {
      return undefined;
    });

    mock('copyFromDataLayer', (dlName) => {
      return undefined;
    });

    mock('getCookieValues', (cookieName, decode) => {
      return [];
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = "";

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
- name: dl with empty values, cookie available
  code: |-
    const mockData = {
      outputType: 'string'
    };

    const log = require('logToConsole');

    mock('copyFromDataLayer', (dlName) => {
      return ",,";
    });

    mock('getCookieValues', (cookieName, decode) => {
      return ['isIABGlobal=false&datestamp=Mon+Aug+09+2021+08:27:26+GMT+0300+(Eastern+European+Summer+Time)&version=6.21.0&landingPath=NotLandingPage&groups=1:1,2:1'];
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = "1:1,2:1";

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
- name: global variable with empty values, cookie available
  code: |-
    const mockData = {
      outputType: 'string'
    };

    const log = require('logToConsole');

    mock('copyFromWindow', (varName) => {
      return ",,";
    });

    mock('getCookieValues', (cookieName, decode) => {
      return ['isIABGlobal=false&datestamp=Mon+Aug+09+2021+08:27:26+GMT+0300+(Eastern+European+Summer+Time)&version=6.21.0&landingPath=NotLandingPage&groups=1:1,2:1'];
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = "1:1,2:1";

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
- name: return only the selected groups status
  code: |-
    const mockData = {
      outputType: 'string',
      returnType: 'selected',
      selectedGroup: 'C0002'
    };

    const log = require('logToConsole');

    mock('copyFromDataLayer', (dlName) => {
      return ",C0001,C0005,C0002,C0004,C0003,";
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = "true";

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
- name: cookie data available, no dataLayer, return an array
  code: |-
    const mockData = {
      outputType: 'array'
    };

    const log = require('logToConsole');

    mock('copyFromDataLayer', (dlName) => {
      return undefined;
    });

    mock('getCookieValues', (cookieName, decode) => {
      return ['isIABGlobal=false&datestamp=Mon+Aug+09+2021+08:27:26+GMT+0300+(Eastern+European+Summer+Time)&version=6.21.0&landingPath=NotLandingPage&groups=1:1,2:1'];
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = ["1:1","2:1"];

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
- name: cookie data available, no global variable, return an array
  code: |-
    const mockData = {
      outputType: 'array'
    };

    const log = require('logToConsole');

    mock('copyFromWindow', (varName) => {
      return undefined;
    });

    mock('getCookieValues', (cookieName, decode) => {
      return ['isIABGlobal=false&datestamp=Mon+Aug+09+2021+08:27:26+GMT+0300+(Eastern+European+Summer+Time)&version=6.21.0&landingPath=NotLandingPage&groups=1:1,2:1'];
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = ["1:1","2:1"];

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
- name: OnetrustActiveGroups dataLayer
  code: |-
    const mockData = {
      outputType: 'string'
    };

    const log = require('logToConsole');

    mock('copyFromDataLayer', (dlName) => {
      if (dlName === 'OnetrustActiveGroups') {
        return ",1,2,3";
      }
      return undefined;
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = "1:1,2:1,3:1";

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
- name: OnetrustActiveGroups global variable
  code: |-
    const mockData = {
      outputType: 'string'
    };

    const log = require('logToConsole');

    mock('copyFromWindow', (varName) => {
      if (varName === 'OnetrustActiveGroups') {
        return ",1,2,3";
      }
      return undefined;
    });

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    log(variableResult);

    const expectedResult = "1:1,2:1,3:1";

    // Verify that the variable result is as expected
    assertThat(variableResult).isEqualTo(expectedResult);
setup: ''


___NOTES___

Created on 8/9/2021, 10:17:29 AM


