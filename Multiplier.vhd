LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY Multiplier IS
    GENERIC (N : NATURAL := 10);
    PORT (
        a : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        b : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        z : OUT STD_LOGIC_VECTOR(2 * N - 1 DOWNTO 0));
END Multiplier;
ARCHITECTURE Multiplier OF Multiplier IS
    TYPE matrix IS ARRAY (N - 1 DOWNTO 0) OF STD_LOGIC_VECTOR (N DOWNTO 0);

    TYPE array1 IS ARRAY (N - 1 DOWNTO 0) OF STD_LOGIC;
    COMPONENT adder IS
        GENERIC (N : NATURAL := 10);
        PORT (
            x, y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            cin : IN STD_LOGIC;
            cout : OUT STD_LOGIC;
            s : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
    END COMPONENT adder;
    SIGNAL co, sel : array1;
    SIGNAL sum, sig, c : matrix;
BEGIN
    l0 : FOR i IN 0 TO N - 1 GENERATE
        l1 : IF (i = (N - 1)) GENERATE
            sel(i) <= '1';
        END GENERATE;
        l2 : IF (i < (N - 1)) GENERATE
            sel(i) <= '0';

        END GENERATE;
        l3 : FOR j IN 0 TO N - 1 GENERATE
            c(i)(j) <= (a(i) AND b(j))XOR sel(i);
        END GENERATE;
        c(i)(N) <= c(i)(N - 1);
    END GENERATE;
    l4 : FOR i IN 0 TO N - 1 GENERATE
        l5 : IF (i = 0) GENERATE
            sum(0) <= c(0)(N DOWNTO 0);
            co(0) <= c(0)(N);
            sig(0) <= co(0) & sum(0)(N DOWNTO 1);
            z(0) <= c(0)(0);
        END GENERATE;
        l6 : IF (i >= 1) GENERATE
            l7 : adder
            GENERIC MAP(N => N + 1)

            PORT MAP(
                x => sig(i - 1),
                y => c(i),
                cin => sel(i),
                cout => co(i),
                s => sum(i));
            sig(i) <= sum(i)(N) & sum(i)(N DOWNTO 1);
            z(i) <= sum(i)(0);
        END GENERATE;
    END GENERATE;
    z(2 * N - 1 DOWNTO N) <= sig(N - 1)(N - 1 DOWNTO 0);
END Multiplier;