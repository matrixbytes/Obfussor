; minimal test case - plaintext string that should be encrypted by Obfuscate's string encryption
@.str = private constant [14 x i8] c"SecretString\00"

declare i32 @puts(i8*)

define i32 @main() {
entry:
  %str_ptr = getelementptr inbounds [14 x i8], [14 x i8]* @.str, i32 0, i32 0
  call i32 @puts(i8* %str_ptr)
  ret i32 0
}
