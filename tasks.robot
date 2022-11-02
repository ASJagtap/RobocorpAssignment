*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.PDF
Library            RPA.Desktop
Library    RPA.Archive
Library    OperatingSystem


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Wait Until Keyword Succeeds    5x    0.5 sec    Preview the robot
        Wait Until Keyword Succeeds    5x    0.5 sec    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${order_records}=    Read table from CSV    orders.csv    header=True
    RETURN    ${order_records}

Close the annoying modal
    Wait And Click Button    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Fill the form
    [Arguments]    ${orderdata}
    Select From List By Value    id:head    ${orderdata}[Head]
    Select Radio Button    body    ${orderdata}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${orderdata}[Legs]
    Input Text    address    ${orderdata}[Address]

Preview the robot
    Click Button    preview
    Wait Until Element Is Visible     preview

Submit the order
    Click button                    order
    Page Should Contain Element     xpath://*[@id="receipt"]

Take a screenshot of the robot
    [Arguments]    ${orderdata}
    Capture Element Screenshot    //*[@id="robot-preview-image"]  ${OUTPUT_DIR}${/}screenshot/robot_preview_image_${orderdata}.png
    [Return]    ${OUTPUT_DIR}${/}screenshot/robot_preview_image_${orderdata}.png

Store the receipt as a PDF file
    [Arguments]    ${orderdata}
    ${receipt_html} =    Get Element Attribute    xpath://*[@id="receipt"]    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}pdf/receipt_${orderdata}.pdf
    [Return]    ${OUTPUT_DIR}${/}pdf/receipt_${orderdata}.pdf


Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    ${image_files} =    Create List    ${screenshot}:align=center
    Add Files To PDF    ${image_files}    ${pdf}    append=True


Create receipt PDF with robot preview image
    [Arguments]    ${orderdata}    ${screenshot}
    ${pdf} =    Store the receipt as a PDF file    ${orderdata}
    Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}


Go to order another robot
    Click Button    xpath://*[@id="order-another"]


Create a ZIP file of the receipts
    ${zip_file_name} =    Set Variable    ${OUTPUT_DIR}${/}all_receipts.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}pdf    ${zip_file_name}
