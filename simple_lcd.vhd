-- composant simple_lcd
-- date de création : 18 mars 2008
-- version : 2.0 for Quartus 7.1
-- by J.Y. Parey
-- annule et remplace la version 1.1 du 26 novembre 2007

-- Afficheur LCD comme 2 lignes de 16 caractéres
-- input/output
-- clk : horloge 50 Mhz
-- ligne : 0 / 1° ligne     1 / 2° ligne
-- place : caractére dans la ligne "0000" 1° caractére à gauche
-- data : code du caractére à afficher
-- pas de gestion handshake
-- synchrone avec l'horloge clk:
-- si wr à 1 et busy à 0 alors
-- le circuit place busy à 1 sauf si uniquement enaligne est à 1, puis
-- effectue les actions en fonction des lignes de commande suivantes: 
-- enaligne : à 1 enregistre ligne et place
-- enadata : à 1 enregistre code caractére et lance l'affichage.
-- enaligne et enadata à 0 : remet à zero ligne et place et le contenu de 
-- l'afficheur LCD.
-- enaligne et enadata peuvent être simultanément à 1 
-- à la fin de l'opération busy repasse à 0 et le processus peut recommancer
-- 					ATTENTION
-- Si wr est maintenu en permanence à 1, 
-- le circuit boucle suivant l'état des lignes d'entrées



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity simple_lcd is
    port (
           ligne    : in std_logic ;
           place 	: in std_logic_vector(3 downto 0);
           data     : in std_logic_vector(7 downto 0);
           enaadd   : in std_logic ;
           enadata  :  in std_logic ;
		   wr       : in  std_logic; 
           clk      : in std_logic;

		   LCD_ON : out std_logic := '1';	
           LCD_EN : out std_logic := '1';
           LCD_RS : out std_logic := '0';
           LCD_RW : out std_logic := '1'; 
           LCD_DATA : inout std_logic_vector(7 downto 0):= "00000000";
		   busy   : out std_logic := '1'
);

end simple_lcd;


architecture Behavioral of simple_lcd is
	signal rw : std_logic :='1';	
	signal tempbusy, busycopy : std_logic :='1'; 
	signal compt : integer range 0 to 10:= 0;	  
	signal pause : integer range 0 to 2000000 := 2000000;
	signal div : std_logic_vector(6 downto 0):="0000000";	 
	signal clig : std_logic_vector(18 downto 0):="0000000000000000000";
	signal DB : std_logic_vector(7 downto 0);
	signal fligne, fraz : std_logic :='0'; 
	signal fcase :std_logic_vector(3 downto 0);
	signal fdata :std_logic_vector(7 downto 0);
	
	
begin
busy <= busycopy ;
	process(clk)
	begin
		if clk'event and clk = '1' then
			if ((wr = '1')and (busycopy = '0')) then
				if enaadd = '1' then
					fligne <= ligne;
					fcase <= place;
				end if;
				if enadata  = '1' then
					busycopy <= '1';
					fdata <= data;
					end if;
				if ((enaadd = '0') and (enadata  = '0')) then
					busycopy <= '1';
					fraz <= '1' ;
				end if ;
			end if;
			
--	génération horloge et synchro
		if( div = "1100011") then
						div <= "0000000";
	  	else 
	   				div <= div+1;
		end if;
		if (div="0001001") then  LCD_EN <= '1';
		end if;
		if ( div = "0111011") then  
			LCD_EN <= '0';
			if clig = "1111111111111111111" then clig <= "0000000000000000000";
			else clig <= clig + 1;
			end if;
		end if;
-- fin génération horloge et synchro
-- y a t il quelque chose a ecrire

-- on remet le systeme en état lecture
		if ( div = "0000000") then
					if (rw='0') then
								rw <= '1' ;
								LCD_RS <= '0'; 
					end if;


		end if;		
		if pause = 0 then
-- test du busy sur le front négatif de l'horloge
-- on génére un signal tempbusy qui indique que l'on peut envoyer une data
					 	if ( div = "0111011") then
									if (rw='1') then
											if LCD_DATA(7)='0' then
													tempbusy <='1';
											end if;
									end if;
						end if;
						
						
-- si tempbusy le permet on envoie une donnée lorsque div = 0
						if ( div = "0000000") then
-- démarrage de l'initialisation
						if tempbusy = '1' then		
	   								case (compt) is
		   								when 0=> 	
												 --	pause <=1000000;
		  											pause <=6666;	 
			  									 	DB <= "00110000";
													compt <= compt+1;
													rw <= '0';
												--	tempbusy <= '0';
		   								when 1=> 
												--	pause <=1000000;	
		  											pause <=180;		  		  
			  										DB <= "00110000";
													compt <= compt+1;
													rw <= '0';
												--	tempbusy <= '0';
 			  								when 2 =>
												--	pause <=1000000;	
		  											pause <=60;	
	  												DB <=  "00110000";
				  									compt <= compt+1;	
													rw <= '0';
												--	tempbusy <= '0';

 	    									when 3 =>
												--	pause <=1000000;
		  											pause <=60;			  
 		  											DB <= "00111100";
 			  										compt <= compt+1;
													rw <= '0';
													tempbusy <= '0';
												--	configure <= '1';
													
	-- on vient d'écrire function set
	-- c'est la fin de la partie ou on ne teste pas le flag	
     										when 4 =>
												--	pause <=1000000;
			  									--	pause <=60;														
	  												DB<="00001100";	
 				  									compt <= compt+1;	
													rw <= '0';
													tempbusy <= '0';
-- on vient d'écrire display on.off control
	    									when 5 =>
												--	pause <=1000000;
			  									--	pause <=60;			
  													DB <= "00000110";
				  									compt <= compt+1;	  
													rw <= '0';
									 				tempbusy <= '0';
-- on vient d'écrire entry mode set
		     								when 6 =>
												--	pause <=1000000;
			  									--	pause <=2000;			  
			  										DB <= "00000001";
													compt <= compt+1;
												 	rw <= '0';
									 				tempbusy <= '0';
													busycopy <= '0';
 -- on vient d'écrire clear display													

-- c'est la fin de l'initialisation de l'interfacz

	    									when 7 =>
-- on attend qu'il y ait une nouvelle valeur a afficher	
													if busycopy = '1' then
																if fraz = '1' then
																fraz <= '0';
																compt <= 6;
																fcase <= "0000";
																fligne <= '0';
																else
																compt <= compt+1;
																end if;
													end if;
													
											when 8 =>
												--	pause <=1000000;		
													compt <= compt+1;
	  												DB(7) <= '1' ;
	  												DB(6) <= fligne ;
													DB(5 downto 4) <= "00";
	  												DB(3 downto 0) <= fcase(3 downto 0);
												--	pause <=60;
													rw <= '0';
										 			tempbusy <= '0';	
-- on vient d'écrire l'adresse
-- on va écrire la data

    										when 9 =>
												--	pause <=1000000;
												--	pause <=60;			 	   
				  									LCD_RS <= '1'; 		
													compt <= compt+1;
	  												DB <= fdata;	
													rw <= '0';
										 			tempbusy <= '0';	

 
   	
											when others => 	
													busycopy <= '0';
		 											rw <='1';	
	 												tempbusy <='0';
													compt <= 7;
	 										--			pause <= 200;
													LCD_RS <= '0'; 
	 												DB <= "00000000";

   									end case;	
  									end if;	
							end if;	  
					else
							if ( div = "0000000") then
									pause <=pause-1;
							end if;
					end if;

 
	end if;
end process;
LCD_RW <=rw;
LCD_ON <= '1';
with rw select
	LCD_DATA <= DB when '0',
			"ZZZZZZZZ" when others;
-- scompt <= compt;
end Behavioral;
