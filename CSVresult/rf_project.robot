*** Settings ***
Library    String
Library    Collections
Library    OperatingSystem
Library    DatabaseLibrary
Library    DateTime
Library    validate.py

*** Variables ***
# Global variables
${PATH}    C:/Users/vikiv/Documents/UiPath/Project1/CSVresult/
@{ListToDB}
${InvoiceNumber}    empty

# database related variables
${dbname}    rpacourse
${dbuser}    robotuser
${dbpass}    password
${dbhost}    localhost
${dbport}    3306

*** Keywords ***
Make Connection
	[Arguments]  ${dbtoconnect}
	Connect To Database  dbapiModuleName=pymysql  dbName=${dbtoconnect}  dbUsername=${dbuser}  dbPassword=${dbpass}  dbHost=${dbhost}  dbPort=${dbport}

Add Row Data to List 
    [Arguments]     ${items}

    @{AddInvoiceRowData}=     Create List
    Append To List    ${AddInvoiceRowData}    ${InvoiceNumber}
    Append To List    ${AddInvoiceRowData}    ${items}[7]
    Append To List    ${AddInvoiceRowData}    ${items}[0]
    Append To List    ${AddInvoiceRowData}    ${items}[1]
    Append To List    ${AddInvoiceRowData}    ${items}[2]
    Append To List    ${AddInvoiceRowData}    ${items}[3]
    Append To List    ${AddInvoiceRowData}    ${items}[4]
    Append To List    ${AddInvoiceRowData}    ${items}[5]

    Append To List    ${ListToDB}    ${AddInvoiceRowData}

*** Keywords ***
Add Invoice Header TO DB
    # validations: 
    # reference number check 
    # iban check 
    # invoice row amount cs header amount 

    [Arguments]    ${items}    ${rows}
    Make Connection    ${dbname}
    
    # 1) Convert dates to correct format
    ${dueDate}=    Convert Date    ${items}[4]    date_format=%d.%m.%Y    result_format=%Y-%m-%d

    # 2) amounts
    # 3) DB create to decimal(10,2)
    ${statusOfInvoice}=    Set Variable    0
    ${commentOfInvoice}=    Set Variable    All ok
    
    ${refResult}=    Is Ref Correct    ${items}[2]
    
    IF    not ${refResult}
        ${statusOfInvoice}=    Set Variable    1
        ${commentOfInvoice}=    Set Variable    Reference number error
    END

    ${ibanResult}=    Check IBAN    ${items}[6]
    
    IF    not ${ibanResult}
        ${statusOfInvoice}=    Set Variable    2
        ${commentOfInvoice}=    Set Variable    IBAN number error
    END

    ${sumResult}=    Check Amounts From Invoice    ${items}[9]    ${rows}

    IF    not ${sumResult}
        ${statusOfInvoice}=    Set Variable    3
        ${commentOfInvoice}=    Set Variable    Amount difference
    END

    ${insertStmt}=    Set Variable    insert into invoiceheader (invoicenumber, companyname, companycode, referencenumber, invoicedate, duedate, bankaccountnumber, amountexclvat, vat, totalamount, invoicestatus_id, comments) values ('${items}[0]', '${items}[1]', '${items}[5]', '${items}[2]', '${innvoiceDate}', '${dueDate}', '${items}[6]', '${items}[7]', '${items}[8]', '${items}[9]', '${statusOfInvoice}', '${commentOfInvoice}');
    #Log    ${insertStmt}
    Execute Sql String    ${insertStmt}

    






*** Test Cases ***
read CSV file to list 
    Make Connection    ${dbname}
    ${outputheader}=    Get File    ${PATH}invoiceHeaders.csv 
    ${outputrows}=    Get File    ${PATH}invoiceRows.csv 
    Log    ${outputheader}
    Log    ${outputrows}

    #lets process each line as an individual element 

    @{headers}=     Split String    ${outputheader}    \n
    @{rows}=     Split String    ${outputrows}    \n


    # remove the first (title) line and the last (empty) line of HEADERS
    ${length}=     Get Length    ${headers}
    ${length}=     Evaluate    ${length}-1 
    ${index}=     Convert To Integer    0
    Remove From List    ${headers}    ${length}
    Remove From List    ${headers}    ${index}

    # remove the first (title) line and the last (empty) line of ROWS
    ${length}=     Get Length    ${rows}
    ${length}=     Evaluate    ${length}-1 
    ${index}=     Convert To Integer    0
    Remove From List    ${rows}    ${length}
    Remove From List    ${rows}    ${index}

    Set Global Variable    ${headers}
    Set Global Variable    ${rows}


