LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY IIR_design IS
    GENERIC (N : NATURAL := 10);
    PORT (
        clk, reset : IN STD_LOGIC;
        xin : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        strobe : IN STD_LOGIC;
        yout : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

END IIR_design;

ARCHITECTURE IIR_design OF IIR_design IS
    COMPONENT Multiplier IS
        GENERIC (N : NATURAL := 10);
        PORT (
            a : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            b : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            z : OUT STD_LOGIC_VECTOR(2 * N - 1 DOWNTO 0));
    END COMPONENT Multiplier;

    COMPONENT adder IS
        GENERIC (N : NATURAL := 10);
        PORT (
            x, y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            cin : IN STD_LOGIC;
            cout : OUT STD_LOGIC;
            s : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
    END COMPONENT adder;

    TYPE array1 IS ARRAY (2 DOWNTO 0)
    OF STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    TYPE array2 IS ARRAY (1 DOWNTO 0)
    OF STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

    SIGNAL N1, N2 : STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
    SIGNAL N3 : STD_LOGIC_VECTOR (N * 2 - 1 DOWNTO 0);
    SIGNAL Nreg, N_inv, x1, acc, x_add : STD_LOGIC_VECTOR (N * 2 - 1 DOWNTO 0);
    SIGNAL enable, inv, load, cout : STD_LOGIC;
    SIGNAL cnt : INTEGER;
    SIGNAL coeffa, coeffb : array1;
    SIGNAL x_delay, y_delay : array2;
BEGIN
    coeffa(0) <= conv_std_logic_vector(INTEGER(128.0 * 1.0000), N);
    coeffa(1) <= conv_std_logic_vector(INTEGER(128.0 * (-0.5643)), N);
    coeffa(2) <= conv_std_logic_vector(INTEGER(128.0 * 0.8167), N);

    coeffb(0) <= conv_std_logic_vector(INTEGER(128.0 * 0.9084), N);
    coeffb(1) <= conv_std_logic_vector(INTEGER(128.0 * (-0.5643)), N);
    coeffb(2) <= conv_std_logic_vector(INTEGER(128.0 * 0.9084), N);

    --kontrolna logika
    control : PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            cnt <= 6;
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (strobe = '1') THEN
                cnt <= 0;
            ELSIF (cnt < 6) THEN
                cnt <= cnt + 1;
            END IF;
        END IF;
    END PROCESS control;
    --kontrolna logika nastavak
    control2 : PROCESS (cnt) IS
    BEGIN
        enable <= '0';
        inv <= '0';
        load <= '0';
        CASE cnt IS
            WHEN 0 => enable <= '1';
            WHEN 1 => enable <= '1';

            WHEN 2 => enable <= '1';
            WHEN 3 => enable <= '1';
                inv <= '1';
            WHEN 4 => enable <= '1';
                inv <= '1';
            WHEN 5 =>
                load <= '1';
            WHEN OTHERS => NULL;
        END CASE;
    END PROCESS control2;

    --   control3 : PROCESS (clk, reset)
    --   BEGIN

    --   END PROCESS control3;
    control3 : PROCESS (cnt, xin, coeffb, coeffa, x_delay, y_delay)
    BEGIN

        CASE(cnt) IS
            WHEN 0 =>
            N1 <= xin;
            N2 <= coeffb(0);
            WHEN 1 =>
            N1 <= x_delay(0);
            N2 <= coeffb(1);
            WHEN 2 =>
            N1 <= x_delay(1);
            N2 <= coeffb(2);
            WHEN 3 =>
            N1 <= y_delay(0);
            N2 <= coeffa(1);
            WHEN 4 =>
            N1 <= y_delay(1);
            N2 <= coeffa(2);
            WHEN 5 =>
            N1 <= (OTHERS => '0');
            N2 <= (OTHERS => '0');
            WHEN OTHERS => NULL;
        END CASE;
    END PROCESS control3;
    l1 : Multiplier
    GENERIC MAP(N => N)

    PORT MAP(
        a => N1,
        b => N2,
        z => N3);
    --shift reg 1
    l2 :
    Nreg <= N3(2 * N - 1) & N3(2 * N - 1) & N3(2 * N - 1 DOWNTO 2);

    --mux21: x1 <= Nreg when inv = '0' else not Nreg;

    invert :
    -- FOR i IN 0 TO N * 2 - 1 GENERATE
    N_inv <= NOT Nreg;

    control4 : PROCESS (inv, Nreg, N_inv)
    BEGIN
        CASE(inv) IS
            WHEN '0' =>
            x1 <= Nreg;
            WHEN '1' =>
            x1 <= N_inv;

            WHEN OTHERS => NULL;
        END CASE;
    END PROCESS control4;
    control5 : adder
    GENERIC MAP(N => N * 2)
    PORT MAP(
        x => x1,
        y => acc,
        cin => inv,
        cout => cout,
        s => x_add);

    contro6 : PROCESS (clk, reset) IS
    BEGIN
        IF reset = '1' THEN
            acc <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF load = '1' THEN
                acc <= (OTHERS => '0');
            ELSIF enable = '1' THEN
                acc <= x_add;
            END IF;
        END IF;
    END PROCESS;

    --    l3 :
    --    FOR i IN 0 TO N - 1 GENERATE
    --        acc1(i) <= acc(i + 5);
    --    END GENERATE;

    REG1 : PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            y_delay(0) <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF load = '1' THEN
                --y_delay(0) <= (OTHERS => '0');
                --ELSIF (enable = '1') THEN
                y_delay(0) <= acc(N + 4 DOWNTO 5);
            END IF;
        END IF;
    END PROCESS REG1;

    REG2 : PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            y_delay(1) <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF load = '1' THEN
                --y_delay(1) <= (OTHERS => '0');
                --ELSIF (enable = '1') THEN
                y_delay(1) <= y_delay(0);
            END IF;
        END IF;
    END PROCESS REG2;

    REG_2 : PROCESS (clk, reset)
    BEGIN

        IF reset = '1' THEN
            x_delay(0) <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF load = '1' THEN
                --x_delay(0) <= (OTHERS => '0');
                --ELSIF (enable = '1') THEN
                x_delay(0) <= xin;
            END IF;
        END IF;
    END PROCESS REG_2;

    REG3 : PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            x_delay(1) <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF load = '1' THEN
                --x_delay(1) <= (OTHERS => '0');
                --  ELSIF (enable = '1') THEN
                x_delay(1) <= x_delay(0);
            END IF;
        END IF;
    END PROCESS REG3;
    yout <= y_delay(0);

END ARCHITECTURE IIR_design;