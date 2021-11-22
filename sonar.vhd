library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar is 
    port( 
        clock:        		in  std_logic; 
        reset:        		in  std_logic; 
        ligar:        		in  std_logic; 
        echo:         		in  std_logic; 
		entrada_serial:		in  std_logic;
        trigger:      		out std_logic;  
        pwm:          		out std_logic; 
        saida_serial: 		out std_logic;
		hex0:			 	out std_logic_vector(6 downto 0);
		hex1:			 	out std_logic_vector(6 downto 0);
		hex2:			 	out std_logic_vector(6 downto 0);
		hex3:			 	out std_logic_vector(6 downto 0);
		hex4:			 	out std_logic_vector(6 downto 0);
		hex5:			 	out std_logic_vector(6 downto 0)
    ); 
end entity;

architecture estrutural of sonar is

	component sonar_fd
		port( 
			clock:        			in  std_logic; 
			reset:        			in  std_logic; 
			conta:        			in  std_logic; 
			transmitir:   			in  std_logic;
			medir:			 		in  std_logic;
			entrada_serial:			in  std_logic;
			echo:         			in  std_logic; 
			trigger:      			out std_logic;  
			pwm:          			out std_logic; 
			pronto_sensor: 			out std_logic;
			pronto_servo: 			out std_logic;
			saida_serial: 			out std_logic;
			distancia2:				out std_logic_vector(3 downto 0);	
			distancia1:				out std_logic_vector(3 downto 0);
			distancia0:				out std_logic_vector(3 downto 0);
			estado_hcsr04:			out std_logic_vector(3 downto 0);
			estado_tx:				out std_logic_vector(3 downto 0);
			estado_rx:				out std_logic_vector(3 downto 0);
			estado_tx_sonar:		out std_logic_vector(3 downto 0)
		); 
	end component;
	
	component sonar_uc
	 port ( 
		clock: 					in  std_logic;
		reset: 					in  std_logic;
		ligar: 					in  std_logic;
		pronto_sensor:			in  std_logic;
		pronto_servo: 		 	in  std_logic;
		medir:					out std_logic;
		conta:					out std_logic;
		zera:						out std_logic;
		transmitir: 			out std_logic;
		db_estado:  			out std_logic_vector(3 downto 0)
    );
	end component;
	
	component hex7seg 
		 port (
			  hexa : in  std_logic_vector(3 downto 0);
			  sseg : out std_logic_vector(6 downto 0)
		 );
	end component;
	
	component mux_4x1_n
		 generic (
			  constant BITS: integer := 4
		 );
		 port ( 
			  D0 :     in  std_logic_vector (BITS-1 downto 0);
			  D1 :     in  std_logic_vector (BITS-1 downto 0);
			  D2 :     in  std_logic_vector (BITS-1 downto 0);
			  D3 :     in  std_logic_vector (BITS-1 downto 0);
			  SEL:     in  std_logic_vector (1 downto 0);
			  MUX_OUT: out std_logic_vector (BITS-1 downto 0)
		 );
	end component;
	
	signal s_zera, s_conta, s_transmitir, s_medir, s_pronto_sensor, s_pronto_servo: std_logic;
	signal s_d0, s_d1, s_d2, s_d3 : std_logic_vector(3 downto 0);
	signal distancia2, distancia1, distancia0: std_logic_vector(3 downto 0);
	signal posicao, estado_hcsr04, estado_tx_sonar, estado_tx, estado_rx: std_logic_vector(3 downto 0);
	signal estado_sonar: std_logic_vector(3 downto 0);
begin

	U1_FD: sonar_fd 
		port map (
			clock, 
			s_zera, 
			s_conta, 
			s_transmitir, 
			s_medir, 
			entrada_serial,
			echo, 
			trigger, 
			pwm,
			s_pronto_sensor, 
			s_pronto_servo, 
			saida_serial, 
			distancia2, 
			distancia1, 
			distancia0, 
			estado_hcsr04, 
			estado_tx, 
			estado_rx, 
			estado_tx_sonar
		);
															
						
	U2_uc: sonar_uc 
		port map (
			clock, 
			reset, 
			ligar, 
			s_pronto_sensor,
			s_pronto_servo, 
			s_medir, 
			s_conta, 
			s_zera, 
			s_transmitir, 
			estado_sonar
		);
	
	-- HEX
	U9_HEX0:  hex7seg port map(distancia2, hex0);
	U10_HEX1: hex7seg port map(distancia1, hex1);
	U11_HEX2: hex7seg port map(distancia0, hex2);
	U12_HEX3: hex7seg port map(estado_hcsr04, hex3);
	U13_HEX4: hex7seg port map(estado_tx, hex4);
	U14_HEX5: hex7seg port map(estado_rx, hex5);
end architecture;
