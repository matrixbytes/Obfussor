; control_flow_flatten.ll
; Simple if/else control flow that a CFF pass should transform into a dispatcher-based flattened CFG

define i32 @main(i32 %x) {
entry:
  %cmp = icmp eq i32 %x, 0
  br i1 %cmp, label %then, label %else

then:
  ; then-block returns 1
  br label %merge

else:
  ; else-block returns 2
  br label %merge

merge:
  %res = phi i32 [1, %then], [2, %else]
  ret i32 %res
}
