namespace PrintSvc.Settings;

public sealed class StorageSettings
{
    public string Endpoint { get; set; } = string.Empty;
    public string AccessKey { get; set; } = string.Empty;
    public string SecretKey { get; set; } = string.Empty;
    public string Bucket { get; set; } = string.Empty;
    public string TempDirectory { get; set; } = "./tmp/";
    public bool UseSSL { get; set; } = false;

    public string GetResolvedTempDirectory()
    {
        string dir = string.IsNullOrWhiteSpace(TempDirectory) ? "./tmp/" : TempDirectory;
        return Path.IsPathRooted(dir)
            ? dir
            : Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, dir));
    }

}
