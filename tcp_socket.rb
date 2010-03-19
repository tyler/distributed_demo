class TCPSocket
  def remote_ip
    peeraddr.last.split(':').last
  end
end
