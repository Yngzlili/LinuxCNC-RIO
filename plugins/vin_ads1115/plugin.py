class Plugin:
    def __init__(self, jdata):
        self.jdata = jdata

    def setup(self):
        return [
            {
                "basetype": "vin",
                "subtype": "vin_ads1115",
                "comment": "4Channel ADC",
                "options": {
                    "name": {
                        "type": "str",
                        "name": "pin name",
                        "comment": "the name of the pin",
                        "default": '',
                    },
                    "net": {
                        "type": "vtarget",
                        "name": "net target",
                        "comment": "the target net of the pin in the hal",
                        "default": '',
                    },
                    "pins": {
                        "type": "dict",
                        "options": {
                            "sda": {
                                "type": "inout",
                                "name": "inout pin SDA",
                            },
                            "scl": {
                                "type": "output",
                                "name": "output pin SCL",
                            },
                        },
                    },
                },
            }
        ]

    def pinlist(self):
        pinlist_out = []
        for num, data in enumerate(self.jdata["plugins"]):
            if data.get("type") == "vin_ads1115":
                pullup = data.get("pullup", True)
                pinlist_out.append(
                    (f"VIN{num}_SDA", data["pins"]["sda"], "INOUT", pullup)
                )
                pinlist_out.append(
                    (f"VIN{num}_SCL", data["pins"]["scl"], "OUTPUT", pullup)
                )
        return pinlist_out


    def vinnames(self):
        ret = []
        for num, data in enumerate(self.jdata["plugins"]):
            if data.get("type") == "vin_ads1115":
                name = data.get("name", f"PV.{num}")
                nameIntern = name.replace(".", "").replace("-", "_").upper()
                function = data.get("function")

                data["_name"] = name + ".0"
                data["_prefix"] = nameIntern + "_0"
                if isinstance(function, list):
                    data["function"] = function[0]
                ret.append(data.copy())

                data["_name"] = name + ".1"
                data["_prefix"] = nameIntern + "_1"
                if isinstance(function, list):
                    data["function"] = function[1]
                ret.append(data.copy())

                data["_name"] = name + ".2"
                data["_prefix"] = nameIntern + "_2"
                if isinstance(function, list):
                    data["function"] = function[2]
                ret.append(data.copy())

                data["_name"] = name + ".3"
                data["_prefix"] = nameIntern + "_3"
                if isinstance(function, list):
                    data["function"] = function[3]
                ret.append(data.copy())
        return ret

    def funcs(self):
        func_out = ["    // vin_ads1115's"]
        for num, data in enumerate(self.jdata["plugins"]):
            if data.get("type") == "vin_ads1115":
                name = data.get("name", f"PV.{num}")
                nameIntern = name.replace(".", "").replace("-", "_").upper()
                func_out.append(f"    vin_ads1115 vin_ads1115{num} (")
                func_out.append("        .clk (sysclk),")
                func_out.append(f"        .i2cSda (VIN{num}_SDA),")
                func_out.append(f"        .i2cScl (VIN{num}_SCL),")
                func_out.append(f"        .adc0 ({nameIntern}_0),")
                func_out.append(f"        .adc1 ({nameIntern}_1),")
                func_out.append(f"        .adc2 ({nameIntern}_2),")
                func_out.append(f"        .adc3 ({nameIntern}_3)")
                func_out.append("    );")
        return func_out

    def ips(self):
        for num, data in enumerate(self.jdata["plugins"]):
            if data["type"] in ["vin_ads1115"]:
                return ["vin_ads1115.v"]
        return []
