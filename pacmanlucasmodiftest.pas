program pacman;

uses
    keyboard,
    crt,
    SysUtils,
    MMSystem;

const
    MAX = 100;

type
    Maze = Array[1..MAX, 1..MAX] of char;
    
    function readChoice(): Integer;
    var
		choice : Integer;
	begin
		write('Please type your choice: ');
		readln(choice);
		readChoice := choice;
	end;


	function readMapFilename(): string;
	var
		choice : Integer;
	begin  
		clrscr();
		TextColor(Yellow);
		writeln('----------------------------------------------------------');
		Writeln('        Available pistes: ''INSA'' and ''STPI''');
		writeln('----------------------------------------------------------');
		Writeln('    1. INSA' );
		Writeln('    2. STPI' );

		
		choice := readChoice();
	
		case (choice) of
		   1: readMapFilename := 'insa.txt';
		   2: readMapFilename := 'stpi.txt';		   
		end;   
	end;
	
	procedure victory(score: Integer);

	begin
		PlaySound('pacman_beginning.wav',0, SND_ASYNC);
		TextColor(LightGreen);
		writeln('----------------------------------------------------------');
		writeln('                        VICTORY');
		writeln('----------------------------------------------------------');
		writeln('');
		writeln('Your score is: ', score);
		writeln('');
		writeln('Press enter to go back to main menu');
		writeln('');
		readln();
	end;
	
	function loadMaze(filename: String; var m: Maze; var width: Integer; var height: Integer; var dots : Integer; var pX: Integer; var pY: Integer): Boolean;
    var
        fp: Text;
        row, col: Integer;
        line: String;
    begin
        if (not FileExists(filename)) then                 // check that file exists
        begin
            writeln('File not found. Aborting load');
            loadMaze := false;
            Exit();
        end;

        writeln('Opening file ... ');

        Assign(fp, filename);                              // assign

        {$i-}
        reset(fp);                                         // open file
        {$i+}

        if (IOResult <> 0) then                            // check that file is accessible
        begin
            writeln('Access denied.');
            loadMaze := false;
            Exit();
        end;

        writeln('Loading maze ... please wait ...');

        read(fp, width);                                   // load dimensions
        readln(fp, height);

        writeln('  Width: ', width);
        writeln('  Height: ', height);

        if (width < 1) or (width > MAX) or (height < 1) or (height > MAX) then
        begin
            writeln('Dimensions out of range');              // check dimensions
            loadMaze := false;
            Exit();
        end;

        // load maze
        for row := 1 to height do                          // for each byte in line
        begin       
            readln(fp, line);                              // read a line
                        
            for col := 1 to width do                       // for each byte in line
            begin
                
                if (line[col]= 'o')then
				begin
					pX:= col;
					pY:= row;
				end else 
					m[col][row] := line[col];
                if (line[col]= '.')or(line[col]= '*') then
					dots:=dots+1;
			end;
        end;

        // close file
        Close(fp);
    end;

    procedure printMaze(m: Maze; width: Integer; height: Integer);
    var
        col, row: Integer;
    begin
        ClrScr();
		
        for col := 1 to width + 2 do
            begin
            TextColor(Red);
            write('_');
            end;
        writeln();

        for row := 1 to height do
        begin
			TextColor(Red);
            write('I');
            for col := 1 to width do
				case (m[col][row]) of
				'#': begin 
						TextColor(Blue);
						Write(m[col][row]);
						end;
				'.': begin 
						TextColor(Yellow);
						Write(m[col][row]);
						end;
				'*': begin 
						TextColor(Magenta);
						Write(m[col][row]);
						end;
				end;
            TextColor(Red); 
            writeln('I');
        end;
		TextColor(Red);
        write('I');
        for col := 1 to width do
            Write('-');
        writeln('I');
    end;


	function initialize(var m: Maze; var width: Integer; var height: Integer; var dots : Integer; var pX: Integer; var pY: Integer) : boolean; 
	var 
		mapfileName : string;
	begin
		dots:=0;
		mapfileName := readMapFilename();
		
		initialize := loadMaze(mapfileName, m, width, height, dots, pX, pY);				
	end;

    procedure navigate(var m: Maze; maxX, maxY: Integer; var dots : Integer; var pX: Integer; var pY: Integer;var score: Integer; var lifes: Integer);
    var
        posX, posY: Integer;
        K: TKeyEvent;
    begin
        posX := pX;
        posY := pY;
        gotoXY(posX + 1, posY + 1);
        write('o');
		

            K := GetKeyEvent();
            K := TranslateKeyEvent(K);
            gotoXY(posX + 1, posY + 1);
            write(' ');

            if (KeyEventToString(K) = 'Right') and (posX < maxX) and (m[posX + 1][posY] <> '#') then
                posX := posX + 1
            else if (KeyEventToString(K) = 'Left') and (posX > 1) and (m[posX - 1][posY] <> '#') then
                posX := posX - 1
            else if (KeyEventToString(K) = 'Up') and (posY > 1) and (m[posX][posY - 1] <> '#') then
                posY := posY - 1
            else if (KeyEventToString(K) = 'Down') and (posY < maxY) and (m[posX][posY + 1] <> '#') then
                posY := posY + 1;
            if m[posX][posY]='.' then
            begin
				PlaySound('pacman_chomp.wav',0, SND_ASYNC);
				m[posX][posY]:=' ';
				score:=score+5;
				dots:=dots-1;
            end;
            if m[posX][posY]='*' then
            begin
				PlaySound('pacman_eatfruit.wav',0, SND_ASYNC);
				m[posX][posY]:=' ';
				score:=score+15;
				dots:=dots-1;
			end;
			pX:= posX;
			pY:= posY;
            gotoXY(posX + 1, posY + 1);
            write('o');



    end; { deplacement }


	procedure play();
	var 
		width, height, dots: Integer;
		m: Maze;	
		success : boolean;	
		lifes: integer;
		score: integer;
		pX,pY : integer;
		
	begin
		lifes:=3;
		score:=0;
		success := initialize(m, width, height, dots, pX, pY);
		
		if (success) then
		begin
			PlaySound('pacman_beginning.wav',0, SND_ASYNC);
			printMaze(m, width, height);
			Delay(4000);
			InitKeyBoard();                 // enable low level keyboard I/O
			repeat
				Navigate(m, width, height, dots, pX, pY, score, lifes);  // navigate(m, width, height);
			until (dots=0)or(lifes=0);
			DoneKeyBoard();                 // disable low level keyboard I/O
			if dots=0 then 
			begin
				clrscr;
				victory(score);
			end;
		end;
				
    
	end;
	
	procedure scoreboard();
	begin
		writeln('*** scoreboard' );
	end;
	
	


	procedure printMenu();
	begin
		clrscr;
		TextColor(Yellow);
		writeln('----------------------------------------------------------');
		writeln('                        Pac-Man ');
		writeln('----------------------------------------------------------');
			
		writeln('     1. Play');
		writeln('     2. Scoreboard');
		writeln('     3. Quit');
	end;
		
	procedure executeChoice(choice : Integer);
    begin       
		case (choice) of
		   1: play();
		   2: scoreboard();		   
		end;      
    end;
      

    


var    
    c : Integer;

begin
	repeat
		printMenu();	
		c := readChoice();	
		executeChoice(c);
	until (c = 3);		
end.

