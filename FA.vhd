
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY FA1 IS
    PORT (
        a : IN STD_LOGIC;
        b : IN STD_LOGIC;
        ci : IN STD_LOGIC;
        co : OUT STD_LOGIC;
        z : OUT STD_LOGIC);
END FA1;
ARCHITECTURE concurrent OF FA1 IS
BEGIN
    z <= a XOR b XOR ci;
    co <= (a AND b) OR (a AND ci) OR (b AND ci);
END ARCHITECTURE concurrent;