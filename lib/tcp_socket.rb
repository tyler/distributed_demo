class TCPSocket
  def remote_ip
    peeraddr.last.split(':').last
  end

  def ready_to_read?(timeout=5)
    r,_,__ = IO.select([self], nil, nil, timeout)
    return r.first == self
  end
end
