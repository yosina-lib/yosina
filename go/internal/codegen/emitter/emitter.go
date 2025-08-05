package emitter

type Emitter struct {
	PackageName string
}

type Artifact struct {
	Filename string
	Content  []byte
}

func New(packageName string) *Emitter {
	return &Emitter{
		PackageName: packageName,
	}
}
