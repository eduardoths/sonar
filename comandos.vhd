library ieee;
use ieee.std_logic_1164.all;

entity comandos is
    port (
        reset:      in  std_logic;
        comando:    in  std_logic_vector(7 downto 0);
        aberto:     out std_logic;
        manual:     out std_logic;
        inverter:   out std_logic
    );
end entity;

architecture arch of comandos is
    signal s_aberto : std_logic := '0';
    signal s_manual : std_logic := '0';
    signal s_inverter : std_logic := '0';
begin
    process (reset, comando)
    begin
		if reset = '1' then
			s_aberto <= '0';
            s_manual <= '0';
            s_inverter <= '0';
        else
            if comando = x"61" then -- a: aberto
                s_aberto <= '1';
            elsif comando = x"66" then -- f: fechar
                s_aberto <= '0';
            elsif comando = x"41" then -- A: automático
                s_manual <= '0';
            elsif comando = x"4D" then -- M: manual
                s_manual <= '1';
            elsif comando = x"69" then -- i: inverter
                s_inverter <= not s_inverter;
            end if;
        end if;
    end process;
    aberto <= s_aberto;
    manual <= s_manual;
    inverter <= s_inverter;
end architecture;