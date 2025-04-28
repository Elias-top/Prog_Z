#Proc defined to parse the jobId from Submit Command (Using for VIVADO CLUSTER)

proc defaultJobIdParser { str } {
  if { [regexp {(\d+)} $str matchresult] } { 
    return $matchresult
  } else {
    return ""
  }
}
