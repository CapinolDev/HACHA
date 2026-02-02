PROGRAM MAIN
USE :: raylib
USE, INTRINSIC :: iso_c_binding 
IMPLICIT NONE
call init_window(500, 500, "GAME" // c_null_char)
do while (.not. window_should_close())
call begin_drawing()
call clear_background(WHITE)
call begin_drawing()
IF (is_key_down(KEY_W)) then
call draw_text("WDOWN" // c_null_char, 100, 100, 40, BLACK)
END IF
IF (is_key_down(KEY_R)) then
call draw_text("RDOWN" // c_null_char, 100, 100, 40, BLACK)
END IF
if (is_mouse_button_down(MOUSE_BUTTON_RIGHT)) then
CALL EXIT(1) 
END IF
call end_drawing()
END DO
call close_window()
END PROGRAM MAIN
