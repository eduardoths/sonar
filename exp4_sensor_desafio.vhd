library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exp4_sensor_desafio is
  port (
    clock      : in std_logic;
    reset      : in std_logic;
    medir      : in std_logic;
    echo       : in std_logic;
	 posicao		: in std_logic_vector (2 downto 0);
    trigger    : out std_logic;
	 db_posicao	: out std_logic_vector (2 downto 0);
	 pwm			: out std_logic;
	 db_pwm		: out std_logic;
    hex0       : out std_logic_vector(6 downto 0); -- digitos da medida
    hex1       : out std_logic_vector(6 downto 0);
    hex2       : out std_logic_vector(6 downto 0);
    pronto     : out std_logic;
    db_trigger : out std_logic;
    db_echo    : out std_logic;
    db_estado  : out std_logic_vector(6 downto 0) -- estado da UC
  );
end exp4_sensor_desafio;

architecture exp4_sensor_arch of exp4_sensor_desafio is
  signal s_trigger : std_logic;
  component edge_detector
    port ( clk         : in   std_logic;
           signal_in   : in   std_logic;
           output      : out  std_logic
    );
  end component;
  component controle_servo
	  port (
			clock    : in  std_logic;
			reset    : in  std_logic;
			posicao  : in  std_logic_vector(2 downto 0);  --  00=0,  01=1ms  10=1.5ms  11=2ms
			db_posicao: out std_logic_vector(2 downto 0);
			db_posicao2: out std_logic_vector(2 downto 0);
			db_reset : out std_logic;
			db_pwm	: out std_logic;
			pwm      : out std_logic );
		end component;

  component interface_hcsr04
    port (
      clock     : in std_logic;
      reset     : in std_logic;
      medir     : in std_logic;
      echo      : in std_logic;
      trigger   : out std_logic;
      medida    : out std_logic_vector(11 downto 0); -- 3 digitos BCD
      pronto    : out std_logic;
      db_estado : out std_logic_vector(3 downto 0) -- estado da UC
    );
  end component;

  component hex7seg
    port (
      hexa : in std_logic_vector(3 downto 0);
      sseg : out std_logic_vector(6 downto 0)
    );
  end component;

  signal s_medir     : std_logic;
  signal s_db_estado : std_logic_vector(3 downto 0);
  signal s_medida    : std_logic_vector(11 downto 0);

begin

  trigger <= s_trigger;
  db_trigger <= s_trigger;

  db : edge_detector port map(
    clock,
    medir,
    s_medir
  );

  hcsr04 : interface_hcsr04 port map(
    clock,
    reset,
    s_medir,
    echo,
    s_trigger,
	 s_medida,
    pronto,
    s_db_estado
  );

  hex_estado : hex7seg port map(
    hexa => s_db_estado,
    sseg => db_estado
  );

  hex_med0 : hex7seg port map(
    hexa => s_medida(3 downto 0),
    sseg => hex0
  );

  hex_med1 : hex7seg port map(
    hexa => s_medida(7 downto 4),
    sseg => hex1
  );

  hex_med2 : hex7seg port map(
    hexa => s_medida(11 downto 8),
    sseg => hex2
  );
  
  servo : controle_servo port map (
	clock       => clock,
	reset       => reset,
	posicao     => posicao,
	db_posicao  => db_posicao,
	db_posicao2 => open,
	db_reset    => open,
	db_pwm	   => db_pwm,
	pwm         => pwm
  );


  db_echo <= echo;  
 end exp4_sensor_arch;