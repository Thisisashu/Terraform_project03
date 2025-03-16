app_environment = {
  production= {
    virtualnetworkname="app-network"
    virtualnetworkcidrblock="10.0.0.0/16"
     subnets = {
  websubnet01={cidrblock="10.0.0.0/24"
  machines={
  webvm01={
    networkinterfacename="webinterface01"
    publicipaddressname="webip01"
  } }
  }
  appsubnet01={cidrblock="10.0.1.0/24"
   machines={
  appvm01={
    networkinterfacename="appinterface01"
    publicipaddressname="appip01"
  }
  }
  }
}
        
  }
}
