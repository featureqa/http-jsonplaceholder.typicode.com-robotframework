import json
import jsonpath

def get_environment():
    fenvironment = open('../../Fixtures/environmentSettings.json')
    envresponse = json.loads(fenvironment.read())
    envValue = jsonpath.jsonpath(envresponse,'environment.type')
    return envValue[0]


def get_global_variables(environmentName, value):
    fvariable = open('../../Fixtures/globalVariables.json')
    response = json.loads(fvariable.read())
    value = jsonpath.jsonpath(response,environmentName + '.' + value)
    return value[0]


def get_expected_value(templatefile, key, value):
    ftemplate = open('../../Fixtures/' + templatefile)
    tresponse = json.loads(ftemplate.read())
    tvalue = jsonpath.jsonpath(tresponse,key + '.' + value)
    return tvalue[0]
   