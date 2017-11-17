
Printing to PDF with AVR Web apps has always been a royal hassle. Doing so required expensive, and challenging to configure, third-party print drivers; low-end print drivers don't work either because they are single-threaded or require registry access to assign a PDF file name at runtime. In the early days of Windows, registry access for such ad hoc tasks was easy but in these security-conscious times it's not an acceptable (or hardly doable) best practice.  

Microsoft has finally come to the rescue by adding native PDF print drives to both Windows 10 and Windows Server 2016 (perhaps signaling that MS realized its XPS document writer isn't a PDF killer!). That's the good news, the bad news is that this PDF print driver is not present, nor is it available, for previous Windows or Windows Server versions. 

>You will need Windows 10 or Windows Server 2016 to get Microsoft's native PDF driver. If you haven't yet upgraded, for those with Web printing needs, the cost of upgrading is partially offset by no longer needing to pay the high cost of third party PDF drivers. As an aside, Windows Server 2012 R2 falls out of mainstream support in October 2018. Plan for that!  

We have tested this Microsoft driver on Windows 10 and Windows Server 2016 and with ASNA VisualRPG 15.0. It isn't formally supported on AVR 14 (the version that works with Visual Studio 15), but this article's code ran just fine with that version.   

### On with the code

The class below in Figure 2a provides the logic to print a report to either a PDF file or a printer. If you compare this code to [other code we've provided to print with PDF](https://asna.com/us/tech/kb/doc/avr-pdf-printing), you'll appreciate how little friction is encountered printing to PDF with the Microsoft PDF driver.  

Depending on how the `CustomerReport` class is instanced, printer output is directed to either a printer or a PDF file. Printing to a printer is usually not a good idea in a Web app. The printing would occur on a printer on the network, which is probably not where there user is--that's the appeal of printing to PDF. It allows the user to print the PDF local or save it for later use. The class allows printing to a printer primarily to show how a single class can easily do double, but related, duty.   

See the embedded comments for details on this class. The code is pretty simple but if the regular expressions in the `CheckFileAndPathSeparators` subroutine causes your eyebrows to furrow, take at look [this article on regular expressions](https://asna.com/us/tech/kb/series/learning-regex/regex-intro).     

<small>Figure 1. The example app to print a simple report with AVR the Web.</small>

<?prettify lang="py" linenums=true?>

	Using System
	Using System.Text.RegularExpressions
	Using System.IO 
	
	/*
	 | This class shows how to print to Microsoft's native PDF
	 | print driver (which produces a PDF file) or to a real printer.
	 |
	 | When printing to the MS native PDF driver, the printer name
	 | must be:
	 |      "Microsoft Print to PDF"
	 |
	 | Use MS Word to save a sample document with this driver to ensure
	 | it is available. It should be present for Windows 10 or Windows 
	 | Server 2016. It is not present, not is it available, for previous
	 | Windows or Windows Server versions.
	 */
	
	BegClass CustomerReport Access(*Public)
	
	    DclDB Name(pgmDB) DBName("*Public/DG NET Local")
	
	    DclDiskFile Cust +
	        Type(*Input) +
	        Org(*Indexed) +
	        Prefix(Cust_) +
	        File("Examples/CMastNewL2") +
	        DB(pgmDB) +
	        ImpOpen(*No) 
	
	    DclPrintFile MyPrint +
	        DB (pgmDB) + 
	        File ("Examples/CustList") + 
	        ImpOpen (*No) 
	    
	    DclProp DocumentName Type (*String) 
	    DclProp IsPdf Type (*Boolean) 
	    DclProp OutputDirectory Type (*String) 
	    DclProp OutputFileFullName Type(*String) Access(*Public) 
	    DclProp PrinterName Type (*String) 
	    DclProp VirtualPathToPdf Type(*String) Access(*Public) 
	
	    BegSr OpenData Access (*Private) 
	        Connect PgmDB
	        Open Cust
	
	        MyPrint.Printer = *This.PrinterName
	        If (IsPdf) 
	            MyPrint.PrintToFileName = *This.OutputFileFullName
	        EndIf             
	        Open MyPrint
	    EndSr
	
	    BegSr CloseData Access (*Private) 
	        Close Cust
	        Close MyPrint
	        Disconnect PgmDB
	    EndSr
	
	    BegSr Print Access(*Public) 
	        OpenData()
	        WriteReportFormats()
	        CloseData()
	        // If printing to PDF, pause just a bit
	        // to ensure the PDF file is closed before
	        // returning.
	        If (*This.IsPdf) 
	            Sleep(5000)
	        EndIf 
	    EndSr
	
	    BegSr WriteReportformats Access (*Private) 
	        DclFld StartingfooterSize Type (*Integer4) 
	        DclFld NeedHeader Type (*Boolean) 
	
	        // There are 254 print units in an inch. 
	        DclConst ONE_INCH Value(254)
	
	        StartingfooterSize = MyPrint.FooterSize
	        NeedHeader = *True
	
	        DclFld Counter Type(*Integer4) 
	
	        Read Cust
	        DoWhile (NOT Cust.IsEof)
	            Counter += 1
	            CustomerName = Cust_CMName
	
	            If (NeedHeader) 
	                Write Heading
	                NeedHeader = *False
	            EndIf
	
	            Write Detail
	            
	            // This results in a 1.25 inch footer. 
	            If (MyPrint.FooterSize <= ONE_INCH * 1.25)
	                Write Footer
	                NeedHeader = *True
	                StartingFooterSize = MyPrint.FooterSize
	            Endif 
	
	            // An arbitrary value to limit pages printed
	            // for testing.
	            If Counter = 75 
	                Leave 
	            EndIf
	
	            Read Cust
	        EndDo
	
	        If (StartingfooterSize <> MyPrint.FooterSize) 
	            Write Footer
	        EndIf
	    EndSr
	
	    BegConstructor Access(*Public) 
	        //
	        // Constructor for printing to printer.
	        //
	        DclSrParm PrinterName Type(*String) 
	
	        *This.PrinterName =	PrinterName
	        *This.IsPdf = *False
	    EndConstructor
	
	    BegConstructor Access(*Public) 
	        //
	        // Constructor for printing to PDF.
	        //
	        DclSrParm WebRoot Type(*String) 
	        DclSrParm OutputDirectory Type(*String) 
	        DclSrParm DocumentName Type(*String)
	        DclSrParm PrinterName Type(*String)
	        
	        DclConst ERROR_MESSAGE Value('There isn''t a [{0}] directory in the app root.') 
	
	        *This.PrinterName = PrinterName
	        
	        CheckFileAndPathSeparators(OutputDirectory, DocumentName)
	
	        // Throw exception if output directory provided doesn't exist.             
	        If NOT Directory.Exists(WebRoot + *This.OutputDirectory )
	            Throw *New System.ArgumentException(String.Format(ERROR_MESSAGE, +
	                                                *This.OutputDirectory))
	        EndIf
	
	        // Create PDF file name. 
	        *This.OutputFileFullName = String.Format('{0}{1}\{2}', +              
	                                       WebRoot, +
	                                       *This.OutputDirectory, +
	                                       *This.DocumentName)
	        
	        // Create relative output file name for response.redirect.
	        *This.VirtualPathToPdf = String.Format('/{0}/{1}', + 
	                                     *This.OutputDirectory, +
	                                     *This.DocumentName)
	        *This.IsPdf = *True
	    EndConstructor
	
	    BegSr CheckFileAndPathSeparators
	        DclSrParm OutputDirectory Type(*String) 
	        DclSrParm DocumentName Type(*String) 
	
	        DclConst BACK_SLASH Value('\') 
	        DclConst FORWARD_SLASH Value('/')
	        DclConst LEADING_BACK_SLASH Value('^\\')
	        DclConst TRAILING_BACK_SLASH Value('\\$')
	
	        // Don't assume the slashes or backslashes provided 
	        // are correct! 
	        // Remove leading backslash if present.
	        *This.OutputDirectory = RegEx.Replace(OutputDirectory, + 
	                                   LEADING_BACK_SLASH, String.Empty)
	        // Remove trailing backslash if present.
	        *This.OutputDirectory = RegEx.Replace(OutputDirectory, + 
	                                   TRAILING_BACK_SLASH, String.Empty) 
	        // Swap / slashes for \ slashes if present.
	        *This.OutputDirectory = RegEx.Replace(OutputDirectory, + 
	                                   FORWARD_SLASH, BACK_SLASH)
	        // Remove leading backslash if present.
	        *This.DocumentName = RegEx.Replace(DocumentName, +
	                                LEADING_BACK_SLASH, String.Empty)
	        // Remove trailing backslash if present.
	        *This.DocumentName = RegEx.Replace(DocumentName, +
	                                TRAILING_BACK_SLASH, String.Empty)
	    EndSr
	    
	EndClass

<small>Figure 2a. An example class to print a report with AVR</small>

An example app to print to the Web is shown below. 

![](https://asna.com/filebin/marketing/article-figures/web-printing.png?x=1510872553176) 

Its code-behind is shown below in Figure 2b. 

<?prettify lang="js" linenums=true?>

	BegClass PrintFromWeb Partial(*Yes) Access(*Public) Extends(System.Web.UI.Page)
	    //
	    // Print to PDF.
	    //
	    BegSr Button1_Click Access(*Private) Event(*This.Button1.Click)
	        DclSrParm sender Type(*Object)
	        DclSrParm e Type(System.EventArgs)
	
	        DclFld report Type(CustomerReport) 
	
	        DclFld WebRoot Type(*String) 
	        DclFld PDFFolder Type(*String) 
	        DclFld PDFFileName Type(*String) 
	        DclFld PrinterName Type(*String) 
	
	        /*
	         | When printing to the MS native PDF driver, the printer name
	         | must be:
	         |      "Microsoft Print to PDF"
	         | Use MS Word to save a sample document with this driver to ensure
	         | it is available. It should be present for Windows 10 or Windows 
	         | Server 2016. It is not present, not is it available, for previous
	         | Windows or Windows Server versions.
	         */
	        DclConst MS_PDF_DRIVER Value('Microsoft Print to PDF')
	
	        WebRoot = Server.MapPath('\')
	        // The PDFFolder is relative to the root.
	        PDFFolder = 'pdf/files'
	        PDFFileName = textboxPDFFileName.Text.Trim()
	        PrinterName =  MS_PDF_DRIVER
	        report = *New CustomerReport(WebRoot, PDFFolder, PDFFileName, PrinterName) 
	        report.Print()                         
	
	        Response.Redirect(report.VirtualPathToPDF)		
	    EndSr	
	
	    //
	    // Print to printer.
	    //
	    BegSr Button2_Click Access(*Private) Event(*This.Button2.Click)
	        DclSrParm sender Type(*Object)
	        DclSrParm e Type(System.EventArgs)
	
	        DclFld report Type(CustomerReport) 
	        DclFld PrinterName Type(*String) 
	
	        PrinterName = textboxPrinterName.Text.Trim() 
	        report = *New CustomerReport(PrinterName)
	        
	        report.Print()                                		
	    EndSr
	EndClass
<small>Figure 2b. AVR code-behind</small using Figure 1a's class.</small>