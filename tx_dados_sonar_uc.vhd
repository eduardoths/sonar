library ieee;
use ieee.std_logic_1164.all;

entity tx_dados_sonar_uc is
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
end entity;


architecture arch of tx_dados_sonar_uc is
	type tipo_estado is (inicial, envia, aguarda, incrementa);
	signal Eatual : tipo_estado;
	signal Eprox  : tipo_estado;
begin

	process (reset, clock)
	begin
		if reset = '1' then
			Eatual <= inicial;
		elsif clock'event and clock = '1' then
			Eatual <= Eprox;
		end if;
end process;
  
  process (transmitir, tx_pronto, j_max, Eatual)
  begin
	  case Eatual is 
			when inicial =>
				if transmitir = '0' then
					Eprox <= inicial;
				else
					Eprox <= envia;
				end if;

			when envia =>
				Eprox <= aguarda;
			
			when aguarda =>
				if tx_pronto = '0' then
					Eprox <= aguarda;
				elsif j_max = '0' then
					Eprox <= incrementa;
				else 
					Eprox <= inicial;
				end if;

			when incrementa =>
				Eprox <= envia;
		end case;
	end process;
	
	with Eatual select zera <=
		'1' when inicial,
		'0' when others;
	
	with Eatual select enviar_tx <=
		'1' when envia,
		'0' when others;
	
	with Eatual select incrementar_j <=
		'1' when incrementa,
		'0' when others;
	
	with Eatual select db_estado <=
		x"0" when inicial,
		x"1" when envia,
		x"2" when aguarda,
		x"3" when incrementa;

end architecture;