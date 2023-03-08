require 'timeout'

#begin
#  Timeout::timeout(time to timeout){
#    evento a se dar timeout
#}

class TCP
  def initialize (estado = "CLOSED")
    @estado = estado
  end

  #com attrr_reader não precisamos criar um metodo p ler estado o próprio ruby faz isso p gente 
  attr_reader :estado

  def recv(recebido)
    #strip para remover whitespace
    case[@estado, recebido.strip]
      #se inicia como closed
      in ["CLOSED", "passive open"]
        @estado = "LISTEN"

      in["CLOSED", "active open"]
        @estado = "SYN_SENT"
        return "SYN"

      in ["LISTEN", "SYN"]
        @estado = "SYN_RCVD"
        return "SYN,ACK"
      
      in["SYN_RCVD", "ACK"]
        @estado = "ESTABLISHED"
      
      in["SYN_RCVD", "RCT"]
        @estado = "LISTEN"

      in["SYN_RCVD", "close"]
        @estado = "FIN_WAIT_1"
      
      in["SYN_SENT", "close"]
        @estado = "CLOSED"

      in ["ESTABLISHED", "close"]
        @estado = "FIN_WAIT_1"
        return "FIN"

      #active close
      in["FIN_WAIT_1", "FIN"]
        @estado = "CLOSING"
        return "ACK"
      
      in["FIN_WAIT_1", "ACK"]
        @estado = "FIN_WAIT_2"

      in["FIN_WAIT_1", "FIN,ACK"]
        @estado = "TIME_WAIT"
        return "ACK"

      in["FIN_WAIT_2", "FIN"]
        @estado = "TIME_WAIT"
        return "ACK"

      in["CLOSING", "ACK"]
        @estado = "TIME_WAIT"

      #passive close
      in ["ESTABLISHED", "FIN"]
        @estado = "CLOSE_WAIT"
        return "ACK"

      in["CLOSE_WAIT", "close"]
        @estado = "LAST_ACK"
        return "FIN"

      in ["LAST_ACK", "ACK"]
        @estado = "CLOSED" 
      
    end
end

tcp = TCP.new()
print("\nEstado: " + String(tcp.estado) + "\n\n")

input = ""
  
loop do 
  if (["SYN_SENT", "SYN_RCVD", "TIME_WAIT"]).include? tcp.estado
    begin
      Timeout::timeout(20){
        print("Envie um Comando: ")
        input = gets()
        print("\nRetornado: " + tcp.recv(input) + "\n\n")
      }
    
    rescue Timeout::Error
      print("\nTIMEOUT\n")
      tcp.estado = "CLOSED"
    end
         
    else
      print("\nEnvie um Comando: ")
      input = gets()
      print("\nRetornado: " + tcp.recv(input) + "\n\n")
      print("Estado da maquina: " + tcp.estado + "\n\n")

  end
end
end