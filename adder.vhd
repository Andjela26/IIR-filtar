LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY adder IS
    GENERIC (N : NATURAL := 16); -- Adder width 
    PORT (
        x, y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        cin : IN STD_LOGIC;
        cout : OUT STD_LOGIC;
        s : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END adder;
ARCHITECTURE structural OF adder IS
    COMPONENT FA1 IS
        PORT (
            a, b, ci : IN STD_LOGIC;
            co, z : OUT STD_LOGIC);
    END COMPONENT FA1;
    SIGNAL c : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
BEGIN
    elements : FOR i IN N - 1 DOWNTO 0 GENERATE
        LSB : IF i = 0 GENERATE
            fad_0 : FA1 PORT MAP(
                a => x(0), b => y(0),
                ci => cin, co => c(0), z => s(0));

        END GENERATE;
        MSBs : IF i > 0 GENERATE
            fad_1 : FA1 PORT MAP(
                a => x(i), b => y(i),
                ci => c(i - 1), co => c(i), z => s(i));
        END GENERATE;
        cout <= c(N - 1);
    END GENERATE;

END ARCHITECTURE structural;