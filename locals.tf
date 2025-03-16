locals {
  resource_location="North Europe"
     networksecuritygroup_rules=[{
      priority =200
      destination_port_range="3389"
     },
     {
     priority=310
     destination_port_range="80"
},
{
     priority=320
     destination_port_range="22"
}
     ]
}