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
${comma}     ,

# database related variables
${dbname}    rpacourse2
${dbuser}    robotuser
${dbpass}    password
${dbhost}    localhost
${dbport}    3306

*** Keywords ***
Make Connection
	[Arguments]  ${dbtoconnect}
	Connect To Database  dbapiModuleName=pymysql  dbName=${dbtoconnect}  dbUsername=${dbuser}  dbPassword=${dbpass}  dbHost=${dbhost}  dbPort=${dbport}

*** Keywords ***
Add Row Data to List          
    [Arguments]    ${items}
    @{AddInvoiceRowData}=    Create List
    Append To List    ${AddInvoiceRowData}    ${InvoiceNumber}   #invoice number
    Append To List    ${AddInvoiceRowData}    ${items}[1]        #company code
    Append To List    ${AddInvoiceRowData}    ${items}[2]        #reference number
    Append To List    ${AddInvoiceRowData}    ${items}[3]        #iban number
    Append To List    ${AddInvoiceRowData}    ${items}[4]        #due date
    Append To List    ${AddInvoiceRowData}    ${items}[5]        #amount excl
    Append To List    ${AddInvoiceRowData}    ${items}[6]        #vat
    Append To List    ${AddInvoiceRowData}    ${items}[7]        #total amount

    
    Append To List    ${ListToDB}    ${AddInvoiceRowData}

*** Keywords ***
Add Invoice Header To DB
    
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


    ${ibanResult}=    Check IBAN    ${items}[3]        
    IF    not ${ibanResult}
        ${statusOfInvoice}=    Set Variable    2
        ${commentOfInvoice}=    Set Variable    IBAN number error
    END

    ${sumResult}=    Check Amounts From Invoice    ${items}[7]    ${rows}     
    IF    not ${sumResult}
        ${statusOfInvoice}=    Set Variable    3
        ${commentOfInvoice}=    Set Variable    Amount difference
    END

    ${amountexc}=     Evaluate     round(${items}[5])

    ${foreignKeyChecks0}=    Set Variable    SET FOREIGN_KEY_CHECKS=0;
    ${insertStmt}=    Set Variable    insert into invoiceheaders (invoiceNumber, companyCode, referenceNumber, ibanNumber, duedate, amountExcl, vat, totalAmount, invoicestatus_id, comments) values ('${items}[0]', '${items}[1]', '${items}[2]', '${items}[3]', '${dueDate}', '${amountexc}', '${items}[6]', '${items}[7]','${statusOfInvoice}', '${commentOfInvoice}');
    Execute Sql String    ${foreignKeyChecks0}
    Execute Sql String    ${insertStmt}

*** Keywords ***
Check Amounts From Invoice
    [Arguments]    ${totalSumFromHeader}    ${invoiceRows}
    ${status}=    Set Variable    ${False}
    ${totalRowsAmount}=    Evaluate    0

    FOR    ${element}    IN    @{invoiceRows}
        Log To Console   ${element}[6]
        ${totalRowsAmount}=    Evaluate    ${totalRowsAmount}+${element}[7]
    END

    ${totalSumFromHeader}=    Convert To Number    ${totalSumFromHeader}
    ${totalRowsAmount}=    Convert To Number    ${totalRowsAmount}
    ${diff}=    Convert To Number    0.01
    
    ${status}=    Is Equal    ${totalSumFromHeader}    ${totalRowsAmount}    ${diff}        
    
    [Return]    ${status}

*** Keywords ***
Check IBAN
    [Arguments]    ${iban}
    ${status}=    Set Variable    ${False}
    ${iban}=    Remove String    ${iban}    ${SPACE}
    ${length}=    Get Length    ${iban}


    IF    ${length} == 18
        ${status}=    Set Variable    ${True}
    END
    [Return]    ${status}

*** Keywords ***
Add Invoice Row To DB
    [Arguments]    ${items}
    Make Connection    ${dbname}
    ${insertStmt}=    Set Variable    insert into invoicerows (invoiceNumber, item, quantity, unit, unitPrice, vatPercent, lineVat, lineItemAmount) values ('${items}[0]', '${items}[1]', '${items}[2]', '${items}[3]', '${items}[4]', '${items}[5]', '${items}[6]', '${items}[7]');
    Execute Sql String    ${insertStmt} 


*** Test Cases ***
Read CSV file to list
    ${outputHeader}=    Get File    ${PATH}invoiceHeaders.csv
    ${outputRows}=    Get File    ${PATH}invoiceRows.csv
    Log    ${outputHeader}
    Log    ${outputRows}

    # Each row read as an element to list 
    @{headers}=    Split String    ${outputHeader}    \n
    @{rows}=    Split String    ${outputRows}    \n
    
    # Remove last row and first row from lists (last=empty and first=header)
    ${length}=    Get Length    ${headers}
    ${length}=    Evaluate    ${length}-1
    ${index}=    Convert To Integer    0
    
    Remove From List    ${headers}    ${length}
    Remove From List    ${headers}    ${index}

    ${length}=    Get Length    ${rows}
    ${length}=    Evaluate    ${length}-1

    Remove From List    ${rows}    ${length}
    Remove From List    ${rows}    ${index}
    
    # Set as global, that we can use same variables in other test cases
    Set Global Variable    ${headers}
    Set Global Variable    ${rows}

    Log     ${headers}
    Log     ${rows}


*** Test Cases ***
Loop all invoicerows
    # Loop through all element is in row list
    FOR    ${element}    IN    @{rows}
        Log    ${element}
        
        # Read all different values as an element from CSV row to items-list
        @{items}=    Split String    ${element}   , 
        Log    ${items}
        ${rowInvoiceNumber}=    Set Variable    ${items}[0]

        Log    ${rowInvoiceNumber}
        Log    ${InvoiceNumber}                  

        IF    '${rowInvoiceNumber}' == '${InvoiceNumber}'
            Log    Let's add rows to the invoice
            Log    ${items}
            Add Row Data to List    ${items}
        ELSE
            # If invoice number changes, we need to check if there are rows going to database
            Log    We need to check if there are already rows in the database list
            Log    ${InvoiceNumber}
            ${length}=    Get Length    ${ListToDB}
            IF    ${length} == ${0}
                Log    The case of the first invoice
                # update invoice number to be handled and set as global
                ${InvoiceNumber}=    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}               

                Add Row Data to List    ${items}
            ELSE
                Log    The invoice changes, the header data must also be processed
                # If invoice is changing we need to find header data
                FOR    ${headerElement}    IN    @{headers}
                    ${headerItems}=    Split String    ${headerElement}    ,         
                    Log    ${headerItems}
                    IF    '${headerItems}[0]' == '${InvoiceNumber}'
                        Log    The invoice was found

                        # Add header data to database using own keyword
                        Add Invoice Header To DB    ${headerItems}    ${ListToDB}        

                        # Add row data to database using own keyword
                        FOR    ${rowElement}    IN    @{ListToDB}
                            Add Invoice Row To DB    ${rowElement}            
                        END                
                    END
                END            
                # Set process for new round
                @{ListToDB}    Create List
                Set Global Variable    ${ListToDB}
                ${InvoiceNumber}=    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}        

                # Add data to global list using own keyword
                Add Row Data to List    ${items}
            END
        END
    END
    # Case for last invoice
    ${length}=    Get Length    ${ListToDB}
    IF    ${length} > ${0}
        Log    Last invoice header processing
        # Find invoice header
        FOR    ${headerElement}    IN    @{headers}
            ${headerItems}=    Split String    ${headerElement}    ,
            IF    '${headerItems}[0]' == '${InvoiceNumber}'
                Log    invoice was found

                # Add header data to database using own keyword
                Add Invoice Header To DB    ${headerItems}    ${ListToDB}

                # Add row data to database using own keyword
                FOR    ${rowElement}    IN    @{ListToDB}
                    Add Invoice Row To DB    ${rowElement}
                END                
            ELSE
                Log    Something is wrong.
            END
        END
    END
