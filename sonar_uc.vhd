library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar_uc is
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
end entity;


architecture uc_arch of sonar_uc is

    type tipo_estado is (desligado, preparacao, mede, transmite, wait0);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

    -- memoria de estado
    process (reset, clock, ligar)
    begin
        if reset = '1' then
            Eatual <= desligado;
		  elsif ligar = '0' then
		      Eatual <= desligado;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

  -- logica de proximo estado
	process (ligar, Eatual, pronto_sensor, pronto_servo) 
	begin
		case Eatual is
			when desligado =>          
				if ligar='1' then 
					Eprox <= preparacao;
				else 
					Eprox <= desligado;
				end if;

			when preparacao => 
				Eprox <= mede;

			when mede =>
				if pronto_sensor='1' then   
					Eprox <= transmite;
				else
					Eprox <= mede;
				end if;

			when transmite =>
				Eprox <= wait0;

			when wait0 =>     
				if pronto_servo='1' then
					Eprox <= mede;
				else
					Eprox <= wait0;
				end if;

			when others => 
				Eprox <= desligado;
		end case;
	end process;

    -- logica de saida
	 with Eatual select zera <= 
		  '1' when preparacao, 
		  '0' when others;
		  
    with Eatual select medir <= 
		  '1' when mede, 
		  '0' when others;
		  
    with Eatual select transmitir <= 
		 '1' when transmite, 
		 '0' when others;

    with Eatual select conta <= 
		  '1' when wait0, 
		  '0' when others;
         
	 -- saida de depuracao
	 with Eatual select db_estado <= 
		"0000" when desligado,
		"0001" when preparacao,
		"0010" when mede,
		"0011" when transmite,
		"0100" when wait0,
		"1010" when others;

end architecture;