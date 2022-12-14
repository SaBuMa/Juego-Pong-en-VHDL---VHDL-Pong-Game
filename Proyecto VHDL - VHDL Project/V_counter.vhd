LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
------------------------------------
ENTITY V_counter IS
	GENERIC	(	N				:	INTEGER	:= 10);
	PORT 		(	clk			: 	IN		STD_LOGIC;
					rst			: 	IN		STD_LOGIC;
					ena			: 	IN		STD_LOGIC;
					syn_clr		:	IN		STD_LOGIC;
					V_activo 	: 	OUT	STD_LOGIC;
					V_sync		: 	OUT	STD_LOGIC;
					V_Counter	: 	OUT	STD_LOGIC_VECTOR (N-1 DOWNTO 0)
					);
END ENTITY;
------------------------------------
ARCHITECTURE rt1 OF V_counter IS
	CONSTANT ONES			:	UNSIGNED (N-1 DOWNTO 0)	:=	(OTHERS => '1');
	CONSTANT ZEROS			:	UNSIGNED (N-1 DOWNTO 0)	:=	(OTHERS => '0');
	-- SIGNAL count_s		:	INTEGER RANGE 0 to (2**N-1);
	
	SIGNAL count_s			:	UNSIGNED (N-1 DOWNTO 0);
	SIGNAL count_next		:	UNSIGNED (N-1 DOWNTO 0);

BEGIN
	-- NEXT STATE LOGIC
	count_next	<=		(OTHERS => '0')	WHEN	syn_clr = '1'  ELSE
							count_s + 1			WHEN	(ena = '1')		ELSE
							count_s;
	PROCESS (clk,rst)
		VARIABLE	temp	:	UNSIGNED(N-1 DOWNTO 0);
	BEGIN
		IF(rst = '1') THEN
			temp :=	(OTHERS => '0');
		ELSIF (rising_edge(clk)) THEN
			IF (ena = '1' AND count_s /= "1000001010") THEN
				temp := count_next;
			ELSIF (ena = '1' AND count_s = "1000001010") THEN
				temp := ZEROS;
			END IF;
		END IF;
		V_Counter <=	STD_LOGIC_VECTOR(temp);
		count_s <=	temp;
	END PROCESS;
	
	--OUTPUT LOGIC
--	V_max		<= '1' WHEN count_s = TO_UNSIGNED(525,N)	ELSE '0';--525 PULSOS/PIXELES
	V_sync	<= '0' WHEN (count_s >= TO_UNSIGNED(0,N) AND count_s <= TO_UNSIGNED(2,N))	ELSE '1';--522 A 3+11+31+480=525 PULSOS/PIEXELES para el sincronizacion Vertical
--	VB_porch <= '1' WHEN (count_s >= TO_UNSIGNED(2,N) AND count_s <= TO_UNSIGNED(35,N))	ELSE '0';--0 A31 PULSOS/PIXELES para el Back Porch Vertical
	V_activo <= '1' WHEN (count_s >= TO_UNSIGNED(35,N) AND count_s <= TO_UNSIGNED(515,N))	ELSE '0';--31 A 480+31=511 PULSOS/PIXELES para la zona activa
--	VF_porch <= '1' WHEN (count_s >= TO_UNSIGNED(515,N) AND count_s <= TO_UNSIGNED(525,N))	ELSE '0';--511 A 11+31+480=522 PULSOS/PIEXELES para el Front Porch Vertical

	
END ARCHITECTURE;