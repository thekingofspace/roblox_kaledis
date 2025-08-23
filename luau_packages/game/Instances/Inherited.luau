return {
    SetAttribute = function(self, Name:string, Value:any)
        local OldAts = self.attributes

        OldAts[Name] = Value

        self.attributes = OldAts

        OldAts = nil
    end,

    GetAttribute = function(self, Name:string)
        return self.attributes[Name]
    end,
}