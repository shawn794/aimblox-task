export type SettingsType = {
    Brightness: number,
    Sounds: boolean,
    InputSens: number,
    Walkspeed: number,
    CharacterScale: number
}

return {
    DefaultSettings = {
        Brightness = 2,
        Sounds = true,
        InputSens = 1,
        WalkSpeed = 20,
        CharacterScale = 1
    }
}