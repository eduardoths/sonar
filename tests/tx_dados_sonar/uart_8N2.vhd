library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart_8N2 is
  port (
    clock             : in std_logic;
    reset             : in std_logic;
	 partida				 : in std_logic;
    dados_ascii       : in std_logic_vector (7 downto 0);
    recebe_dado       : in std_logic;
	 pronto_rx         : out std_logic;
	 pronto_tx         : out std_logic;
    tem_dado          : out std_logic;
    dado_recebido     : out std_logic_vector (7 downto 0);
	 saida_serial		 : out std_logic;
	 db_estado_tx		 : out std_logic_vector(3 downto 0);
	 db_estado_rx		 : out std_logic_vector(3 downto 0)
  );
end entity;

architecture uart_8N2_arch of uart_8N2 is
	component contadorg_m
		generic (constant M : integer);
		port (
			clock, zera_as, zera_s, conta : in std_logic;
			Q                             : out std_logic_vector(natural(ceil(log2(real(M)))) - 1 downto 0);
			fim, meio                     : out std_logic
		);
	end component;
	component tx_serial_8E2
	port (
		clock, reset, partida: in  std_logic;
		config_modo:				 in  std_logic;
		dados_ascii:           in  std_logic_vector (7 downto 0);
		saida_serial, pronto : out std_logic;
		db_estado: 				 out std_logic_vector(3 downto 0)
	);
end component;
	
	component rx_serial_8N2
		port (
			clock             : in std_logic;
			reset             : in std_logic;
			dado_serial       : in std_logic;
			recebe_dado       : in std_logic;
			pronto_rx         : out std_logic;
			tem_dado          : out std_logic;
			dado_recebido		 : out std_logic_vector (7 downto 0);
			db_estado         : out std_logic_vector (3 downto 0)
	);
	end component;
	
	signal s_dado_serial: std_logic;
	signal s_tick: std_logic;
	
	begin
	
	tx: tx_serial_8E2 port map (
		clock 			=> clock,
		reset 			=> reset,
		partida 			=> partida,
		config_modo 	=> '0',
		dados_ascii 	=> dados_ascii,
		saida_serial 	=> saida_serial,
		pronto 			=> pronto_tx,
		db_estado 		=> db_estado_tx
	);
	
	rx: rx_serial_8N2 port map (
		clock 			=> clock,
		reset 			=> reset,
		dado_serial 	=> s_dado_serial,
		recebe_dado 	=> recebe_dado,
		pronto_rx 		=> pronto_rx,
		tem_dado 		=> tem_dado,
		dado_recebido 	=> dado_recebido,
		db_estado 		=> db_estado_rx
	);

end architecture;