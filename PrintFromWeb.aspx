<%@ Page Language="AVR" AutoEventWireup="false" CodeFile="PrintFromWeb.aspx.vr" Inherits="PrintFromWeb" %>

<!doctype html>
<html lang="en">

<head>
    <title>ASNA Print Example</title>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/css/bootstrap.min.css" integrity="sha384-PsH8R72JQ3SOdhVi3uxftmaW6Vc51MKb0q5P2rRUpPvrszuE4W1povHYgTpBfshb" crossorigin="anonymous">

    <style>
        .container  {
          padding-top: 3rem;
        }
    </style>
</head>

<body>
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
      <a class="navbar-brand" href="#">ASNA Web printing example with native Windows PDF driver</a>
      <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
    </nav>
    <div class="container">
        <form id="form1" runat="server">
            <h4>Print to PDF file</h4> 
            <div class="form-row">               
                <div class="form-group col-md-2">
                    <asp:Button class="form-control" ID="Button1" runat="server" Text="Print to PDF file" Width="149px" />
                </div>
                <div class="form-group col-md-6">
                    <asp:TextBox class="form-control" ID="textboxPDFFileName" runat="server" placeholder="PDF file name (including .pdf extension)"></asp:TextBox>
                </div>
            </div>
            
            <h4>Print to printer</h4> 
            <div class="form-row">
                <div class="form-group col-md-2">
                    <asp:Button class="form-control" ID="Button2" runat="server" Text="Print to printer" Width="149px" />
                </div>
                <div class="form-group col-md-6">
                    <asp:TextBox class="form-control" ID="textboxPrinterName" runat="server" placeholder="Printer name"></asp:TextBox>
                </div>
            </div>
        </form>
    </div>

    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.3/umd/popper.min.js" integrity="sha384-vFJXuSJphROIrBnz7yo7oB41mKfc8JzQZiCq4NCceLEaO4IHwicKwpJf9c9IpFgh" crossorigin="anonymous"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/js/bootstrap.min.js" integrity="sha384-alpBpkh1PFOepccYVYDB4do5UnbKysX5WZXm3XxPqe5iKTfUKjNkCk9SaVuEZflJ" crossorigin="anonymous"></script>
</body>

</html>
