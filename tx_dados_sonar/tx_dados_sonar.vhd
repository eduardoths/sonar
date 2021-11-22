library ieee;
use ieee.std_logic_1164.all;

entity tx_dados_sonar is 
	port (
		clock:           	in  std_logic; 
		reset:           	in  std_logic; 
		transmitir:      	in  std_logic; 
		distancia2:      	in  std_logic_vector(7 downto 0); -- e de distancia  
		distancia1:      	in  std_logic_vector(7 downto 0); 
		distancia0:      	in  std_logic_vector(7 downto 0); 
		saida_serial:    	out std_logic; 
		pronto:          	out std_logic;  
		db_transmitir:   	out std_logic; 
		db_saida_serial: 	out std_logic; 
		db_estado:       	out std_logic_vector(3 downto 0);
		db_estado_tx:		out std_logic_vector(3 downto 0);
		db_estado_rx:		out std_logic_vector(3 downto 0)
	);
end entity;

architecture arch of tx_dados_sonar is
	component tx_dados_sonar_fd is 
		port (
			clock:           	in  std_logic; 
			reset:           	in  std_logic;
			zera:					in  std_logic; -- sinal de controle
			enviar_tx:			in  std_logic; -- sinal de controle
			incrementar_j:		in  std_logic; -- sinal de controle
			distancia2:      	in  std_logic_vector(7 downto 0); -- e de distancia  
			distancia1:      	in  std_logic_vector(7 downto 0); 
			distancia0:      	in  std_logic_vector(7 downto 0); 
			saida_serial:    	out std_logic; 
			tx_pronto:        out std_logic; -- sinal de condicao
			j_max:				out std_logic; -- sinal de condicao
			db_estado_tx:		out std_logic_vector(3 downto 0);
			db_estado_rx:		out std_logic_vector(3 downto 0)

		);
	end component;

	component tx_dados_sonar_uc is
		port (
			clock:			in  std_logic;
			reset:			in  std_logic;
			transmitir:		in  std_logic;
			tx_pronto:		in  std_logic; -- sinal de condicao
			j_max:			in  std_logic; -- sinal de condicao
			zera:				out std_logic; -- sinal de controle
			enviar_tx:		out std_logic; -- sinal de controle
			incrementar_j:	out std_logic; -- sinal de controle
			db_estado: 		out std_logic_vector(3 downto 0)
		);
	end component;

   component edge_detector is 
		port ( 
			clk         : in   std_logic;
			signal_in   : in   std_logic;
			output      : out  std_logic
		);
	end component;
	
	-- AUX
	signal s_transmitir, s_transmitir_ed, s_saida_serial: std_logic;
	
	-- Sinal de condicao
	signal s_tx_pronto, s_j_max: std_logic;
	
	-- Sinal de controle
	signal s_zera, s_enviar_tx, s_incrementar_j: std_logic;
	
begin
	TR: edge_detector port map (
		clk			=> clock,
		signal_in 	=> s_transmitir,
		output		=> s_transmitir_ed
	);
	
	UC: tx_dados_sonar_uc port map (
			clock				=> clock,
			reset				=> reset,
			transmitir		=> s_transmitir_ed,
			tx_pronto		=> s_tx_pronto,
			j_max				=> s_j_max,
			zera				=> s_zera,
			enviar_tx		=> s_enviar_tx,
			incrementar_j	=> s_incrementar_j,
			db_estado 		=> db_estado
		);
	
	FD: tx_dados_sonar_fd port map(
			clock           	=> clock,
			reset           	=> reset,
			zera					=> s_zera,
			enviar_tx			=> s_enviar_tx,
			incrementar_j		=> s_incrementar_j,
			angulo2         	=> angulo2,
			angulo1         	=> angulo1,
			angulo0         	=> angulo0,
			distancia2      	=> distancia2,  
			distancia1      	=> distancia1,
			distancia0      	=> distancia0,
			saida_serial    	=> s_saida_serial,
			tx_pronto        	=> s_tx_pronto,
			j_max					=> s_j_max,
			db_estado_tx		=> db_estado_tx,
			db_estado_rx		=> db_estado_rx
	);
	
	saida_serial <= s_saida_serial;
	pronto <= s_tx_pronto AND s_j_max;
	s_transmitir <= transmitir;
	
	db_transmitir <= s_transmitir;
	db_saida_serial <= s_saida_serial;

end architecture;