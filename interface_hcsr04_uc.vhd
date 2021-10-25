library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04_uc is
  port (
    clock, reset, medir                      : in std_logic;
    pulso_subida, pulso_descida              : in std_logic;
    gera_pulso, mede_distancia, pronto, zera : out std_logic;
    db_estado                                : out std_logic_vector(3 downto 0)
  );

end interface_hcsr04_uc;

architecture interface_hcsr04_uc_arch of interface_hcsr04_uc is

  type tipo_estado is (inicial, medindo, espera, conta, final);
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

  process (medir, pulso_subida, pulso_descida, Eatual)
  begin

    case Eatual is

      when inicial =>
        if medir = '0' then
          Eprox <= inicial;
        else
          Eprox <= medindo;
        end if;

      when medindo =>
        Eprox <= espera;

      when espera =>
        if pulso_subida = '0' then
          Eprox <= espera;
        else
          Eprox <= conta;
        end if;

      when conta =>
        if pulso_descida = '0' then
          Eprox <= conta;
        else
          Eprox <= final;
        end if;

      when final =>
        Eprox <= inicial;

      when others =>
        Eprox <= inicial;

    end case;
  end process;

  with Eatual select zera <=
    '1' when medindo,
    '0' when others;
  
  with Eatual select gera_pulso <=
    '1' when medindo,
    '0' when others;
  
  with Eatual select mede_distancia <=
    '1' when conta,
    '0' when others;
  
  with Eatual select pronto <=
    '1' when final,
    '0' when others;

  with Eatual select db_estado <= 
		"0000" when inicial,
		"0001" when medindo,
		"0010" when espera,
		"0011" when conta,
		"0100" when final,
		"0000" when others;
end interface_hcsr04_uc_arch;
  