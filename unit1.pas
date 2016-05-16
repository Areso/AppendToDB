{
 This is free programm under GPLv2 (or later - as option) license.
 Authors: Anton Gladyshev
 version 0.0.0.2 date 2016-05-04
                     (YYYY-MM-DD)
}
unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, sqldb, FileUtil, Forms, Controls, Graphics,
  Dialogs, LazUtils, LConvEncoding;


type

  { TForm1 }

  TForm1 = class(TForm)

    DBConnection: TIBConnection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure reading();
    procedure inserting();
    procedure FormCreate(Sender: TObject);

  private
    { private declarations }
  public

    { public declarations }
  end;

var
  Form1: TForm1;
  f:             text;
  LongString:    widestring;
  records_code:  array of widestring;
  records_groupr:array of widestring;
  records_descrr:array of widestring;
  records_uom:   array of widestring;
  i:             integer; //array of records size
  serv_i1:       integer;
  serv_i2:       integer;
  f2:            text;
  role:          widestring;
  lang:          widestring;
  HostNameDB:    widestring;
  DBName:        widestring;
  DBUsername:    widestring;
  DBPassword:    widestring;
implementation

{$R *.lfm}
procedure TForm1.reading();
begin
  AssignFile(f,'sample.csv');
  i:=0;
  SetLength(records_code,   i+1);
  SetLength(records_groupr, i+1);
  SetLength(records_descrr, i+1);
  SetLength(records_uom, i+1);
  Try
    // try to open file, read variables and close file
    reset(f);
    While Not EOF(f) Do
      begin
      readln(f,LongString);
      //looking for code
      serv_i1:=Pos(',',LongString);
      serv_i2:=Length(LongString);
      records_code[i]:=Copy(LongString,0,serv_i1-1);
      LongString:=Copy(LongString,serv_i1+1,serv_i2);
      //looking for group
      serv_i1:=Pos(',',LongString);
      serv_i2:=Length(LongString);
      records_groupr[i]:=Copy(LongString,0,serv_i1-1);
      LongString:=Copy(LongString,serv_i1+1,serv_i2);
      //looking for description
      serv_i1:=Pos(',',LongString);
      serv_i2:=Length(LongString);
      records_descrr[i]:=Copy(LongString,0,serv_i1-1);
      LongString:=Copy(LongString,serv_i1+1,serv_i2);
      //looking for units of measure
      serv_i2:=Length(LongString);
      records_uom[i]:=Copy(LongString,0,serv_i2-1);

      ShowMessage(records_code[i]+records_groupr[i]+records_descrr[i]+records_uom[i]);

      i:=i+1;
      SetLength(records_code,   i+1);
      SetLength(records_groupr, i+1);
      SetLength(records_descrr, i+1);
      SetLength(records_uom,    i+1);
      end;
    CloseFile(f);
  Except
    //Halt;
  end;
end;

procedure TForm1.inserting();
var
  inn: integer;
  txtt: widestring;
begin
  SQLQuery1.Close;
  SQLQuery1.SQL.Clear;
  SQLQuery1.SQL.Text      := 'execute block as begin ';
  {
  inn:=0;
  for inn:=0 to i-1 do //i
  begin
    //'' are missed in SQL query text
    SQLQuery1.SQL.Text := SQLQuery1.SQL.Text + ' INSERT INTO MAIN (CODE,GROUPR,DESCRR,UOM) VALUES ('
    +''''+records_code[inn]+''''+','
    +''''+records_groupr[inn]+''''+','
    +''''+records_descrr[inn]+''''+','
    +''''+records_uom[inn]+''''+');';
  end;
  SQLQuery1.SQL.Text := SQLQuery1.SQL.Text + ' end';
  }
  records_groupr[0]:=UTF8ToANSI('ква ква');
  inn:=0;
  for inn:=0 to i-1 do
  begin
    SQLQuery1.SQL.Text := ' INSERT INTO MAIN (CODE,GROUPR,DESCRR,UOM) VALUES ('
    +''''+records_code[inn]+''''+','
    +''''+records_groupr[inn]+''''+','
    +''''+records_descrr[inn]+''''+','
    +''''+records_uom[inn]+''''+');';


  ShowMessage(SQLQuery1.SQL.Text);// for debug purpose
  DBConnection.Connected  := True;
  // IF DataSet is open then transaction should be Commit and started again
  If SQLTransaction1.Active Then SQLTransaction1.Commit;
  SQLTransaction1.StartTransaction;

  Try
     //// try open DataSet
     SQLQuery1.ExecSQL;
     ShowMessage('hello');
  Except
     // somthing goes wrong, get out of here and rollback transaction
     SQLTransaction1.Rollback;
  end;
  end;
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  AssignFile(f2,'settings.txt');
  Try
    reset(f2);
    readln(f2, role); //now we keep calm and load our role
    role := UTF8BOMToUTF8(role);
    readln(f2, lang);
    readln(f2, HostNameDB);
    readln(f2, DBName);
    readln(f2, DBUsername);
    readln(f2, DBPassword);
  Except
    //HALT
  end;
  DBConnection.HostName       := HostNameDB;
  DBConnection.DatabaseName   := DBName;
  DBConnection.UserName       := DBUsername;
  DBConnection.Password       := DBPassword;
  reading();
  inserting();
End;



end.

