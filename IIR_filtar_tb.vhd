LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE STD.TEXTIO.ALL;
USE STD.TEXTIO;

-- Add your library and packages declaration here ...
ENTITY iir_design_tb IS
    -- Generic declarations of the tested unit
    GENERIC (
        N : NATURAL := 10);
END iir_design_tb;
ARCHITECTURE TB_ARCHITECTURE OF iir_design_tb IS

    COMPONENT IIR_design IS
        GENERIC (N : NATURAL := 10);
        PORT (
            clk, reset : IN STD_LOGIC;
            xin : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            strobe : IN STD_LOGIC;
            yout : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';
    SIGNAL xin : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL strobe : STD_LOGIC := '0';
    SIGNAL yout : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

    FILE INFILE : TEXT OPEN READ_MODE IS "ECG.txt";
    CONSTANT precision : POSITIVE := 10;
    SUBTYPE int IS
    INTEGER RANGE -2 ** (precision - 1) TO 2 ** (precision - 1) - 1;
    TYPE array1 IS ARRAY(0 TO 249) OF int;
    SIGNAL ECG : array1 := (OTHERS => 0);
    SIGNAL ENDSIM : BOOLEAN := false;
    CONSTANT CLK_PERIOD : TIME := 100 ns;
BEGIN
    UUT : IIR_design
    GENERIC MAP(N => N)
    PORT MAP(
        clk => clk,
        reset => reset,
        xin => xin,
        strobe => strobe,
        yout => yout
    );

    main : PROCESS IS
        PROCEDURE read_ECG_data IS
            VARIABLE IN_LINE : LINE;
            -- pointer to string
            VARIABLE XIN_TEMP : int;
        BEGIN
            FOR j IN 0 TO 249 LOOP
                -- end file checking
                readline(INFILE, IN_LINE);
                -- read line of a file
                read(IN_LINE, XIN_TEMP);
                -- each READ procedure extracts data
                ECG(j) <= XIN_TEMP;
            END LOOP;
        END PROCEDURE;

    BEGIN
        read_ECG_data;
        WAIT FOR 10ns;
        reset <= '1';
        WAIT FOR CLK_PERIOD;
        reset <= '0';
        FOR k IN 0 TO 9 LOOP
            FOR j IN 0 TO 249 LOOP

                xin <= conv_std_logic_vector(ECG(j), N);
                WAIT FOR CLK_PERIOD;
                strobe <= '1';
                WAIT FOR CLK_PERIOD;
                strobe <= '0';
                WAIT FOR CLK_PERIOD * 100;
            END LOOP;
        END LOOP;
        ENDSIM <= true;
        WAIT;
    END PROCESS main;
    CLK_GEN : PROCESS
    BEGIN
        IF ENDSIM = false
            THEN
            clk <= '0';
            WAIT FOR CLK_PERIOD/2;

            clk <= '1';
            WAIT FOR CLK_PERIOD/2;
        ELSE
            WAIT;
        END IF;
    END PROCESS;
END TB_ARCHITECTURE;