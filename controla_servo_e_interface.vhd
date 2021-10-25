library ieee;
library interface_hcsr04;
library utils;
use utils.all;
use interface_hcsr04.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity controla_servo_e_interface is 
	port ( 
		clock:      in  std_logic;  
		reset:      in  std_logic; 
		echo:       in  std_logic; 
      conta:   	in  std_logic;
		medir:		in  std_logic;
		trigger:    out std_logic; 
		distancia0: out std_logic_vector(7 downto 0); -- digitos da medida 
		distancia1:       out std_logic_vector(7 downto 0);  
		distancia2:       out std_logic_vector(7 downto 0); 
		angulo0:       out std_logic_vector(7 downto 0); 
		angulo1:       out std_logic_vector(7 downto 0); 
		angulo2:      out std_logic_vector(7 downto 0); 
		pwm:           out std_logic; 
		pronto_sensor:     out std_logic; 
		pronto_servo:     out std_logic;
		db_echo:    out std_logic; 
		db_estado:  out std_logic_vector(3 downto 0);
      db_pwm:        out std_logic;
      posicao:       out std_logic_vector (2 downto 0)
    ); 
end entity controla_servo_e_interface;
architecture estrutural of controla_servo_e_interface is
	
	component interface_hcsr04 
		port ( 
		clock:     in  std_logic;  
		reset:     in  std_logic; 
		medir:     in  std_logic; 
		echo:      in  std_logic; 
		trigger:   out std_logic; 
		medida:    out std_logic_vector(11 downto 0);
		pronto:    out std_logic; 
		db_estado: out std_logic_vector(3 downto 0)
    ); 
	end component;

	component movimentacao_servomotor 
		port ( 
        clock:         	in  std_logic;  
        reset:         	in  std_logic; 
        ligar:   	 	  	in  std_logic;
        posicao:       	out std_logic_vector (2 downto 0);
        pwm:           	out std_logic; 
		  db_pwm:			out std_logic;
		  pronto1s:		  	out std_logic
		);
	end component;

	component contadorg_m 
		generic (
			constant M: integer := 50 -- modulo do contador
		);
		port (
			clock, zera_as, zera_s, conta: in std_logic;
			Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
			fim, meio: out std_logic 
		);
	end component;
	
	component rom_8x24 
		port ( 
        endereco: in  std_logic_vector(2 downto 0);
        saida   : out std_logic_vector(23 downto 0)
		);
	end component;
	


begin

end architecture;